#!/usr/bin/env bash
# Semantic version bump helper.
#
# Usage:
#   scripts/version.sh major|minor|patch [--dry-run] [--no-tag]
#   scripts/version.sh build
#
# major|minor|patch:
#   Bumps the MAJOR.MINOR.PATCH core in package.json/package-lock.json (via
#   `npm version`), commits it, and creates an annotated `vX.Y.Z` git tag.
#   Requires a clean working tree.
#
# build:
#   Read-only. Prints a build-identifier string for the *current* released
#   version, e.g. `1.2.3-build.42.a1b2c3d`, without touching git or
#   package.json. Used by CI to produce a unique, traceable Docker image tag
#   for every build of the same release (many builds can share one
#   major/minor/patch). If $GITHUB_OUTPUT is set, also writes `version=...`
#   there for use in later workflow steps.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

usage() {
  echo "Usage: $0 <major|minor|patch> [--dry-run] [--no-tag]" >&2
  echo "       $0 build" >&2
  exit 1
}

[[ $# -ge 1 ]] || usage
command="$1"
shift

dry_run=false
make_tag=true
for arg in "$@"; do
  case "$arg" in
    --dry-run) dry_run=true ;;
    --no-tag) make_tag=false ;;
    *)
      echo "Unknown option: $arg" >&2
      usage
      ;;
  esac
done

current_version() {
  node -p "require('./package.json').version"
}

case "$command" in
  major | minor | patch)
    if [[ -n "$(git status --porcelain)" ]] && [[ "$dry_run" == false ]]; then
      echo "error: working tree is not clean. Commit or stash changes before bumping the version." >&2
      exit 1
    fi

    old_version="$(current_version)"

    if [[ "$dry_run" == true ]]; then
      new_version="$(node -e "
        const [major, minor, patch] = '$old_version'.split('.').map(Number);
        const bump = { major: [major + 1, 0, 0], minor: [major, minor + 1, 0], patch: [major, minor, patch + 1] }['$command'];
        console.log(bump.join('.'));
      ")"
      echo "dry run: $old_version -> $new_version (no files changed, no commit, no tag)"
      exit 0
    fi

    new_version="$(npm version "$command" --no-git-tag-version | sed 's/^v//')"

    git add package.json package-lock.json
    git commit -m "chore: bump version to v${new_version}"

    if [[ "$make_tag" == true ]]; then
      git tag -a "v${new_version}" -m "v${new_version}"
      echo "Bumped ${old_version} -> ${new_version}, committed, and tagged v${new_version}."
      echo "Push with: git push --follow-tags"
    else
      echo "Bumped ${old_version} -> ${new_version} and committed (no tag created)."
      echo "Push with: git push"
    fi
    ;;

  build)
    version="$(current_version)"
    build_number="${GITHUB_RUN_NUMBER:-$(git rev-list --count HEAD)}"
    short_sha="$(git rev-parse --short HEAD)"
    # Docker tags don't allow "+", so this deviates slightly from strict SemVer
    # build-metadata syntax (which would use "+") in favor of "-".
    full_version="${version}-build.${build_number}.${short_sha}"

    echo "$full_version"

    if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
      echo "version=${full_version}" >>"$GITHUB_OUTPUT"
    fi
    ;;

  *)
    usage
    ;;
esac
