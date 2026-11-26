import { execFileSync } from 'node:child_process';
import { existsSync, mkdtempSync, readdirSync, readFileSync, rmSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { gunzipSync } from 'node:zlib';

const SURY = 'https://packages.sury.org/php';
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

/** The value of `pattern`'s first group, which every flavour's Dockerfile of the version must agree on. */
function pinned(version, pattern, what) {
    const values = new Set();
    for (const flavor of readdirSync(join('eol', version))) {
        const dockerfile = join('eol', version, flavor, 'Dockerfile');
        const match = readFileSync(dockerfile, 'utf8').match(pattern);
        if (!match) {
            throw new Error(`${dockerfile} has no ${what}`);
        }
        values.add(match[1]);
    }
    if (values.size !== 1) {
        throw new Error(`the Dockerfiles pin different ${what}s: ${[...values].join(', ')}`);
    }
    return [...values][0];
}

/** Package name → its version and debian tarball URL, from deb.sury.org's index of source packages. */
async function latestBuilds() {
    const response = await download(`${SURY}/dists/${distribution}/main/source/Sources.gz`);
    const index = gunzipSync(Buffer.from(await response.arrayBuffer())).toString('utf8');
    const builds = new Map();
    for (const stanza of index.split(/\n\s*\n/)) {
        const name = stanza.match(/^Package: (\S+)$/m)?.[1];
        const version = stanza.match(/^Version: (\S+)$/m)?.[1];
        const directory = stanza.match(/^Directory: (\S+)$/m)?.[1];
        const tarball = stanza.match(/^ [0-9a-f]{32} \d+ (\S+\.debian\.tar\.xz)$/m)?.[1];
        if (name && version && directory && tarball && !builds.has(name)) {
            builds.set(name, { version, tarball: `${SURY}/${directory}/${tarball}` });
        }
    }
    return builds;
}

function parseSeries(text) {
    return text
        .split('\n')
        .map((line) => line.trim().split(/\s+/)[0])
        .filter((name) => name && !name.startsWith('#'));
}

/** The git tree id and series of the build's debian/patches, as Salsa would hash that directory. */
async function builtPatches(build) {
    const dir = mkdtempSync(join(process.env.RUNNER_TEMP || tmpdir(), 'track-patches-'));
    try {
        const response = await download(build.tarball);
        writeFileSync(join(dir, 'debian.tar.xz'), Buffer.from(await response.arrayBuffer()));
        execFileSync('tar', ['-xJf', 'debian.tar.xz', 'debian/patches'], { cwd: dir });
        const git = (...args) => execFileSync('git', args, { cwd: dir, encoding: 'utf8' }).trim();
        git('init', '--quiet');
        git('add', '--force', 'debian/patches');
        return {
            tree: git('write-tree', '--prefix=debian/patches/'),
            series: parseSeries(readFileSync(join(dir, 'debian', 'patches', 'series'), 'utf8')),
        };
    } finally {
        rmSync(dir, { recursive: true, force: true });
    }
}

async function salsaList(path) {
    const items = [];
    for (let page = 1; ; page++) {
        const response = await download(`${SALSA_API}${path}&per_page=100&page=${page}`);
        items.push(...(await response.json()));
        if (!response.headers.get('x-next-page')) {
            return items;
        }
    }
}

/** The newest of the last 100 commits touching debian/patches on the version's branch whose debian/patches is `tree`. */
async function matchingCommit(version, tree) {
    const branch = encodeURIComponent(`debian/main/${version}`);
    const response = await download(`${SALSA_API}/repository/commits?ref_name=${branch}&path=debian/patches&per_page=100`);
    for (const commit of await response.json()) {
        const entries = await salsaList(`/repository/tree?path=debian&ref=${commit.id}`);
        if (entries.find((entry) => entry.name === 'patches')?.id === tree) {
            return commit.id;
        }
    }
    return null;
}

async function seriesPatches(commit) {
    const response = await download(`${SALSA}/-/raw/${commit}/debian/patches/series`);
    return parseSeries(await response.text());
}

// Matched in order on names without the number: deb.sury.org renumbers the series, and names such
// as Fix-test.patch repeat, so neither exact names nor a set of bare names tell which one changed.
function diffSeries(before, after) {
    const bare = (name) => name.replace(/^\d+-/, '');
    const a = before.map(bare);
    const b = after.map(bare);
    const common = Array.from({ length: a.length + 1 }, () => new Uint16Array(b.length + 1));
    for (let i = a.length - 1; i >= 0; i--) {
        for (let j = b.length - 1; j >= 0; j--) {
            common[i][j] = a[i] === b[j] ? common[i + 1][j + 1] + 1 : Math.max(common[i + 1][j], common[i][j + 1]);
        }
    }
    const added = [];
    const removed = [];
    for (let i = 0, j = 0; i < a.length || j < b.length; ) {
        if (i < a.length && j < b.length && a[i] === b[j]) {
            i++;
            j++;
        } else if (j === b.length || (i < a.length && common[i + 1][j] >= common[i][j + 1])) {
            removed.push(before[i++]);
        } else {
            added.push(after[j++]);
        }
    }
    return { added, removed };
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
    const pinnedRevision = pinned(version, /PHP_PATCHES="deb\.sury\.org-([^"]+)"/, 'PHP_PATCHES revision');
    const pinnedCommit = pinned(version, /DEB_PATCHES=\S*\/archive\/([0-9a-f]{40})\//, 'DEB_PATCHES commit');
    const build = builds.get(`php${version}`);
    if (!build) {
        throw new Error(`no php${version} build in the deb.sury.org index`);
    }
    const revision = build.version.replace(/^\d+:/, '').split('+')[0];
    if (revision === pinnedRevision) {
        console.log(`PHP ${version}: up to date (${build.version})`);
        return;
    }

    const { tree, series } = await builtPatches(build);
    const [commit, before] = await Promise.all([matchingCommit(version, tree), seriesPatches(pinnedCommit)]);
    const { added, removed } = diffSeries(before, series);

    const title = `PHP ${version} patches: new deb.sury.org build ${revision}`;
    const body = [
        `deb.sury.org published \`${build.version}\`. Our Dockerfiles pin \`${pinnedRevision}\`, from Salsa commit [\`${pinnedCommit.slice(0, 12)}\`](${SALSA}/-/commit/${pinnedCommit}).`,
        '',
        ...(commit
            ? [
                  `Salsa commit [\`${commit.slice(0, 12)}\`](${SALSA}/-/commit/${commit}) has the same \`debian/patches\` as the build.`,
                  '',
                  `Changes: ${SALSA}/-/compare/${pinnedCommit}...${commit}`,
              ]
            : [
                  `No recent commit on \`debian/main/${version}\` has the same \`debian/patches\` as the build (tree \`${tree}\`): find it by hand.`,
              ]),
        '',
        'Patches added to its series:',
        ...(added.length ? added.map((name) => `- \`${name}\``) : ['None.']),
        '',
        'Patches removed from its series:',
        ...(removed.length ? removed.map((name) => `- \`${name}\``) : ['None.']),
        '',
        `To update, set the new commit in \`DEB_PATCHES\` and the revision in \`PHP_PATCHES\` in every \`eol/${version}/*/Dockerfile\`, review each new patch into \`eol/patches/series.${version}\`, applied or commented out, and drop the removed ones from it.`,
    ].join('\n');

    const existing = issues.find((issue) => issue.title.startsWith(`PHP ${version} patches:`));
    if (existing) {
        await github('PATCH', `/repos/${repository}/issues/${existing.number}`, { title, body });
        console.log(`PHP ${version}: updated issue #${existing.number} (${build.version})`);
    } else {
        const issue = await github('POST', `/repos/${repository}/issues`, { title, body });
        console.log(`PHP ${version}: opened issue #${issue.number} (${build.version})`);
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
