cask "snow-shot-mini" do
  version "1.3.1"
  sha256 "8a57c2f5bae3942e29ee07094b9f6479747ffa3538dece1df3c64cfa784a3f16"

  url "https://github.com/mg-chao/snow-apps/releases/download/v#{version}_snow-shot/snow-shot-mini-#{version}-macos-arm64-homebrew.tar.gz"
  name "Snow Shot Mini"
  desc "Screenshot and screen recording application"
  homepage "https://snowshot.top/"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "Snow Shot Mini.app"
  # Installer scripts run before app artifacts and preserve HOME and Keychain access.
  installer script: {
    executable:   "/bin/bash",
    args:         [staged_path.join("prepare-snow-shot-homebrew.sh"),
                   staged_path.join("snow-shot-mini-#{version}-macos-arm64.dmg"),
                   staged_path.join("Snow Shot Mini.app"),
                   "mini"],
    must_succeed: true,
    print_stderr: true,
  }

  # Homebrew removes the app; retain the signing identity and user data.
  uninstall quit: "com.snowshot.snow_shot_mini"

  caveats <<~EOS
    Snow Shot Mini reuses a signing identity in your login Keychain. The first install
    may request Keychain access. Grant Screen Recording and Accessibility when
    macOS requests them. Local signing does not provide Apple notarization.
    Keep ~/Library/Application Support/Snow Shot Mini/Installer and its Keychain
    identity across upgrades and reinstalls. Use the same installing account.
  EOS
end
