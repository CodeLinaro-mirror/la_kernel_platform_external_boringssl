# Updating BoringSSL from upstream

## Automated updates

Routine updates from upstream `main` are imported into `src/` via Copybara,
which updates `NOTICE`, `BORINGSSL_REVISION`, and `METADATA` and uploads a
Gerrit change for review.

Soong source lists in `sources.bp` use filegroup globs validated against
`src/gen/sources.json` by `boringssl_sources_test` in presubmit, and
`CMakeLists.txt` includes `src/gen/sources.cmake` directly. If an upstream
roll fails `boringssl_sources_test`, update the corresponding filegroup in
`sources.bp` on the roll change.

## Manual rollup to upstream HEAD

* Start a new feature branch, _e.g._ `repo start upstream-update .`
* Run `./update-upstream.sh`.  This will update all of `src/` from upstream HEAD
and generate a git commit on the current branch with a commit message which
is a summary of all the upstream commits since the last time this script was run.
* Amend the commit message with any special notes: `git commit --amend`.
This step is required even if you make no edits in
order to add a `Change-Id` tag for Gerrit.  TODO(prb) automate this.
* Test locally, _i.e._ build, flash and run `MtsConscryptTestCases`.
* Upload for review: `repo upload --cbr -o nokeycheck .`

## Update to an upstream branch
#### (_e.g._ for FIPS)


As per the previous section but add the branch name to the update command line,
_e.g._ `./update-upstream.sh fips-20250305`
