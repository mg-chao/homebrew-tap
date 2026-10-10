cask "snow-shot@beta" do
  version "1.1.7-beta"
  sha256 "107bd9199cb85fae4a2a3469666f451ee63b74f2554fe86f89133258ed07d50e"

  url "https://github.com/mg-chao/snow-apps/releases/download/v#{version}/snow-shot-#{version}-macos-arm64-homebrew.tar.gz"
  name "Snow Shot"
  desc "Screenshot and screen recording application"
  homepage "https://snowshot.top/"

  conflicts_with cask: "snow-shot"
  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "Snow Shot.app"

  # Installer scripts run before app artifacts and preserve HOME and Keychain access.
  installer script: {
    executable:   "/bin/bash",
    args:         [staged_path.join("prepare-snow-shot-homebrew.sh"),
                   staged_path.join("snow-shot-#{version}-macos-arm64.dmg"),
                   staged_path.join("Snow Shot.app")],
    must_succeed: true,
    print_stderr: true,
  }

  # Homebrew removes the app; retain the signing identity and user data.
  uninstall quit: "com.snowshot.snow_shot"

  caveats <<~EOS
    Snow Shot reuses a signing identity in your login Keychain. The first install
    may request Keychain access. Grant Screen Recording and Accessibility when
    macOS requests them. Local signing does not provide Apple notarization.
    Keep ~/Library/Application Support/Snow Shot/Installer and its Keychain
    identity across upgrades and reinstalls. Use the same installing account.
  EOS
end
