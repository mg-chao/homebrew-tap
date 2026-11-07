cask "snow-shot" do
  arch arm: "arm64", intel: "x86_64"

  version "1.5.0"
  sha256 arm:   "f3a640332923a1c2b97765dae67ccf9d223518220cfb818a86630e08075868db",
         intel: "29bfe6df2f44d8051071d6b52557ac07c7f1496185bee8a01b26d6a528ef90e1"

  url "https://github.com/mg-chao/snow-apps/releases/download/v#{version}_snow-shot/snow-shot-#{version}-macos-#{arch}-homebrew.tar.gz"
  name "Snow Shot"
  desc "Screenshot and screen recording application"
  homepage "https://snowshot.top/"

  depends_on macos: :sequoia

  app "Snow Shot.app"
  # Vendor installers preserve HOME and Keychain access; flight steps isolate HOME.
  installer script: {
    executable:   "/bin/bash",
    args:         [staged_path.join("prepare-snow-shot-homebrew.sh"),
                   staged_path.join("snow-shot-#{version}-macos-#{arch}.dmg"),
                   staged_path.join("Snow Shot.app")],
    must_succeed: true,
    sudo:         false,
    print_stderr: true,
  }

  # Remove any prepared copy; the app artifact removes the installed app.
  # Keep the installing account's persistent signing identity and state.
  uninstall script: {
    executable: "/bin/rm",
    args:       ["-rf", "--", "#{staged_path}/Snow Shot.app"],
    sudo:       false,
  }

  caveats <<~EOS
    Snow Shot reuses a signing identity in your login Keychain. The first install
    may request Keychain access. Grant Screen Recording and Accessibility when
    macOS requests them. Local signing does not provide Apple notarization.
    Keep ~/Library/Application Support/Snow Shot/Installer and its Keychain
    identity across upgrades and reinstalls. Use the same installing account.
  EOS
end
