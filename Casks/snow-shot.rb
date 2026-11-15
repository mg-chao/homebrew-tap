cask "snow-shot" do
  arch arm: "arm64", intel: "x86_64"

  version "1.5.8"
  sha256 arm:   "1047ec51053bd3392f37e17d7725cceeb30b898690422006f00fd68661f8a240",
         intel: "b2ad1d7f591c4301074387bab53d4711c5e251dfa3f606a65e149a1a1f78754a"

  url "https://github.com/mg-chao/snow-shot/releases/download/v#{version}_snow-shot/snow-shot-#{version}-macos-#{arch}-homebrew.tar.gz"
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
