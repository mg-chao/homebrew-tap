cask "snow-shot-mini" do
  version "1.2.3"
  sha256 "a3145ba3b740dfaac94384be399edd4520d746eb65b5693aeba91afe566f637a"

  url "https://github.com/mg-chao/snow-apps/releases/download/v#{version}_snow-shot/snow-shot-mini-#{version}-macos-arm64-homebrew.tar.gz"
  name "Snow Shot Mini"
  desc "Screenshot and screen recording application"
  homepage "https://snowshot.top/"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "Snow Shot Mini.app"

  # Third-party Ruby hooks preserve the desktop user's HOME and Keychain access.
  preflight do
    system_command "/bin/bash",
                   args:         [staged_path.join("prepare-snow-shot-homebrew.sh"),
                                  staged_path.join("snow-shot-mini-#{version}-macos-arm64.dmg"),
                                  staged_path.join("Snow Shot Mini.app"),
                                  "mini"],
                   must_succeed: true,
                   print_stdout: true,
                   print_stderr: true
  end

  caveats <<~EOS
    Snow Shot Mini reuses a signing identity in your login Keychain. The first install
    may request Keychain access. Grant Screen Recording and Accessibility when
    macOS requests them. Local signing does not provide Apple notarization.
    Keep ~/Library/Application Support/Snow Shot Mini/Installer and its Keychain
    identity across upgrades and reinstalls. Use the same installing account.
  EOS
end
