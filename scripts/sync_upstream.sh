#!/bin/bash
# Prepare both branches locally; publish only after external validation succeeds.
set -euo pipefail
git config user.name 'github-actions[bot]'
git config user.email '41898282+github-actions[bot]@users.noreply.github.com'
git fetch origin main patch-1
git fetch https://github.com/mg-chao/homebrew-tap.git main
upstream_sha=$(git rev-parse FETCH_HEAD)
git switch -C sync-main origin/main
git merge --no-edit "$upstream_sha"
git switch -C sync-patch origin/patch-1
if ! git merge --no-commit --no-ff sync-main; then
  # Casks are intentionally regenerated from upstream; do not resolve other conflicts.
  conflicts=$(git diff --name-only --diff-filter=U)
  if [[ -z "$conflicts" ]] || printf '%s\n' "$conflicts" | rg -q -v '^Casks/'; then
    git merge --abort
    echo 'Conflict outside managed Casks; manual review required.' >&2
    exit 1
  fi
fi
git rm -r -f --ignore-unmatch Casks
git restore --source="$upstream_sha" --staged --worktree -- Casks
python3 scripts/patch_casks.py
git add Casks
if [[ -f .git/MERGE_HEAD ]] || ! git diff --cached --quiet; then
  git commit -m "Sync upstream ${upstream_sha:0:12} and migrate Snow Shot installer hooks"
fi
printf 'Upstream: %s\nMain candidate: %s\nPatch candidate: %s\n' \
  "$upstream_sha" "$(git rev-parse sync-main)" "$(git rev-parse sync-patch)"
