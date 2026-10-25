import { existsSync, readdirSync, readFileSync } from 'node:fs';
import { join } from 'node:path';
import { gunzipSync } from 'node:zlib';

const SALSA = 'https://salsa.debian.org/php-team/php';
const SALSA_API = 'https://salsa.debian.org/api/v4/projects/php-team%2Fphp';

const token = process.env['INPUT_TOKEN'];
const distribution = process.env['INPUT_DISTRIBUTION'] || 'trixie';
const repository = process.env.GITHUB_REPOSITORY;
const githubApi = process.env.GITHUB_API_URL || 'https://api.github.com';

// Salsa sometimes answers with a 502, so server and network errors are retried.
async function download(url, attempts = 5) {
    for (let attempt = 1; ; attempt++) {
        const response = await fetch(url).catch((error) => ({ ok: false, status: 0, error }));
        if (response.ok) {
            return response;
        }
        const clientError = response.status >= 400 && response.status < 500;
        if (clientError || attempt === attempts) {
            throw new Error(`${url}: ${response.error?.message ?? `HTTP ${response.status}`}`);
        }
        await new Promise((resolve) => setTimeout(resolve, attempt * 3000));
    }
}

async function github(method, path, body) {
    const response = await fetch(`${githubApi}${path}`, {
        method,
        headers: {
            accept: 'application/vnd.github+json',
            authorization: `Bearer ${token}`,
            'content-type': 'application/json',
            'x-github-api-version': '2022-11-28',
        },
        body: body && JSON.stringify(body),
    });
    if (!response.ok) {
        throw new Error(`GitHub API ${method} ${path}: HTTP ${response.status} ${await response.text()}`);
    }
    return response.json();
}

/** The EOL versions: every eol/<X.Y> with a cli Dockerfile. */
function eolVersions() {
    return readdirSync('eol', { withFileTypes: true })
        .filter((entry) => entry.isDirectory() && existsSync(join('eol', entry.name, 'cli', 'Dockerfile')))
        .map((entry) => entry.name)
        .sort();
}

/** The Salsa commit pinned in DEB_PATCHES, which every flavour of the version must agree on. */
function pinnedCommit(version) {
    const commits = new Set();
    for (const flavor of readdirSync(join('eol', version))) {
        const dockerfile = join('eol', version, flavor, 'Dockerfile');
        const match = readFileSync(dockerfile, 'utf8').match(/DEB_PATCHES=\S*\/archive\/([0-9a-f]{40})\//);
        if (!match) {
            throw new Error(`${dockerfile} has no DEB_PATCHES commit`);
        }
        commits.add(match[1]);
    }
    if (commits.size !== 1) {
        throw new Error(`the Dockerfiles pin different commits: ${[...commits].join(', ')}`);
    }
    return [...commits][0];
}

/** Package name → version, from deb.sury.org's index of source packages. */
async function latestBuilds() {
    const response = await download(`https://packages.sury.org/php/dists/${distribution}/main/source/Sources.gz`);
    const index = gunzipSync(Buffer.from(await response.arrayBuffer())).toString('utf8');
    const builds = new Map();
    for (const stanza of index.split(/\n\s*\n/)) {
        const name = stanza.match(/^Package: (\S+)$/m)?.[1];
        const version = stanza.match(/^Version: (\S+)$/m)?.[1];
        if (name && version && !builds.has(name)) {
            builds.set(name, version);
        }
    }
    return builds;
}

/**
 * Splits a build version such as "1:7.4.33-31+0~20261021.121+debian13~1.gbpe9c428" into its
 * revision without epoch ("7.4.33-31") and the start of the Salsa commit it was built from
 * ("e9c428").
 */
function parseBuild(version) {
    const match = version.match(/^(?:\d+:)?([^+]+)\+.*\.gbp([0-9a-f]+)$/);
    return match && { revision: match[1], commitPrefix: match[2] };
}

async function fullCommit(prefix) {
    const response = await download(`${SALSA_API}/repository/commits/${prefix}`);
    return (await response.json()).id;
}

async function seriesPatches(commit) {
    const response = await download(`${SALSA}/-/raw/${commit}/debian/patches/series`);
    return (await response.text())
        .split('\n')
        .map((line) => line.trim().split(/\s+/)[0])
        .filter((name) => name && !name.startsWith('#'));
}

async function openIssues() {
    const issues = [];
    for (let page = 1; ; page++) {
        const batch = await github('GET', `/repos/${repository}/issues?state=open&per_page=100&page=${page}`);
        issues.push(...batch.filter((issue) => !issue.pull_request));
        if (batch.length < 100) {
            return issues;
        }
    }
}

async function check(version, builds, issues) {
    const pinned = pinnedCommit(version);
    const build = builds.get(`php${version}`);
    const parsed = build && parseBuild(build);
    if (!parsed) {
        throw new Error(`no php${version} build with a commit in the deb.sury.org index (got ${build ?? 'nothing'})`);
    }
    if (pinned.startsWith(parsed.commitPrefix)) {
        console.log(`PHP ${version}: up to date (${build})`);
        return;
    }

    const latest = await fullCommit(parsed.commitPrefix);
    const [before, after] = await Promise.all([seriesPatches(pinned), seriesPatches(latest)]);
    const added = after.filter((name) => !before.includes(name));

    const title = `PHP ${version} patches: new deb.sury.org build ${parsed.revision}`;
    const body = [
        `deb.sury.org published \`${build}\`, built from Salsa commit [\`${latest.slice(0, 12)}\`](${SALSA}/-/commit/${latest}). Our Dockerfiles pin [\`${pinned.slice(0, 12)}\`](${SALSA}/-/commit/${pinned}).`,
        '',
        `Changes: ${SALSA}/-/compare/${pinned}...${latest}`,
        '',
        'Patches added to its series:',
        ...(added.length ? added.map((name) => `- \`${name}\``) : ['None.']),
        '',
        `To update, set the new commit in \`DEB_PATCHES\` and the revision in \`PHP_PATCHES\` in every \`eol/${version}/*/Dockerfile\`, and review each new patch into \`eol/patches/series.${version}\`, applied or commented out.`,
    ].join('\n');

    const existing = issues.find((issue) => issue.title.startsWith(`PHP ${version} patches:`));
    if (existing) {
        await github('PATCH', `/repos/${repository}/issues/${existing.number}`, { title, body });
        console.log(`PHP ${version}: updated issue #${existing.number} (${build})`);
    } else {
        const issue = await github('POST', `/repos/${repository}/issues`, { title, body });
        console.log(`PHP ${version}: opened issue #${issue.number} (${build})`);
    }
}

try {
    const builds = await latestBuilds();
    const issues = await openIssues();
    for (const version of eolVersions()) {
        try {
            await check(version, builds, issues);
        } catch (error) {
            console.log(`::error::PHP ${version}: ${error.message}`);
            process.exitCode = 1;
        }
    }
} catch (error) {
    console.log(`::error::${error.message}`);
    process.exitCode = 1;
}
