cask "snow-shot-mini" do
  version "1.5.6"
  sha256 "e669d2e72378ac27f81607bb1491815390c4b1021072c870492b136694e781c0"

  url "https://github.com/mg-chao/snow-shot/releases/download/v#{version}_snow-shot/snow-shot-mini-#{version}-macos-arm64-homebrew.tar.gz"
  name "Snow Shot Mini"
  desc "Screenshot and screen recording application"
  homepage "https://snowshot.top/"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "Snow Shot Mini.app"
  # Vendor installers preserve HOME and Keychain access; flight steps isolate HOME.
  installer script: {
    executable:   "/bin/bash",
    args:         [staged_path.join("prepare-snow-shot-homebrew.sh"),
                   staged_path.join("snow-shot-mini-#{version}-macos-arm64.dmg"),
                   staged_path.join("Snow Shot Mini.app"),
                   "mini"],
    must_succeed: true,
    sudo:         false,
    print_stderr: true,
  }

  # Remove any prepared copy; the app artifact removes the installed app.
  # Keep the installing account's persistent signing identity and state.
  uninstall script: {
    executable: "/bin/rm",
    args:       ["-rf", "--", "#{staged_path}/Snow Shot Mini.app"],
    sudo:       false,
  }

  caveats <<~EOS
    Snow Shot Mini reuses a signing identity in your login Keychain. The first install
    may request Keychain access. Grant Screen Recording and Accessibility when
    macOS requests them. Local signing does not provide Apple notarization.
    Keep ~/Library/Application Support/Snow Shot Mini/Installer and its Keychain
    identity across upgrades and reinstalls. Use the same installing account.
  EOS
end
