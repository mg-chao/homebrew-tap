# Maintained Snow Shot tap

GitHub Actions runs at minute 17 of every hour (UTC), and can also be started
manually from the Actions tab. GitHub may delay scheduled runs and automatically
disables schedules in public repositories after 60 days without repository
activity. Re-enable the workflow in Actions if this happens.

`main` contains upstream's latest content plus this automation. `patch-1`
contains the same content with deprecated Snow Shot preparation hooks migrated
to `installer script:`. All files under `Casks/` on `patch-1` are managed:
each run restores that directory from upstream and reapplies the migration.
Make persistent repair changes in `scripts/patch_casks.py` on `main`, rather
than editing generated casks. No branch is force-pushed; existing history remains.

The script retains upstream versions, download URLs, checksums, architectures,
preparation arguments and output handling. It adds `uninstall quit:` using the
application bundle identifiers; Homebrew's `app` artifact removes the bundle.
Signing identities and installer state are retained. If upstream removes the
legacy hook, its implementation is used unchanged. Unknown hooks, changed
preparation arguments, or conflicts outside Casks stop publication for review.

Both branches are pushed atomically only after migration tests, Ruby syntax,
Homebrew loading on both architectures, and cask audit pass. These checks do
not install or launch Snow Shot and do not verify the interactive Keychain flow.
The workflow uses only its built-in GITHUB_TOKEN with contents:write.

## Existing local installation

Keep the existing `mg-chao/tap` name so installed cask records still resolve:

```sh
git -C "$(brew --repository mg-chao/tap)" remote set-url origin https://github.com/cyruss648/homebrew-tap.git
git -C "$(brew --repository mg-chao/tap)" fetch origin
git -C "$(brew --repository mg-chao/tap)" switch --track origin/patch-1
git -C "$(brew --repository mg-chao/tap)" remote set-head origin patch-1
brew update
brew info --cask mg-chao/tap/snow-shot
```

Homebrew uses `origin/HEAD` to select the update branch. Keep it pointing to
`origin/patch-1`; running `git remote set-head origin --auto` would reset it to
the fork's default branch (`main`). Normal `brew update` fetches the repaired
branch, and normal `brew upgrade` installs available new versions. A cask-only
repair does not require reinstalling the same app version.

For a new machine, tap the fork, then explicitly select its repaired branch:

```sh
brew tap cyruss648/tap
git -C "$(brew --repository cyruss648/tap)" switch --track origin/patch-1
git -C "$(brew --repository cyruss648/tap)" remote set-head origin patch-1
brew install --cask cyruss648/tap/snow-shot
```
