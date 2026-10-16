cask "snow-shot" do
  arch arm: "arm64", intel: "x86_64"

  version "1.3.1"
  sha256 arm:   "fe13c079268a6f1b1a473b42952ca17e4e90a5c0296004d4802e59be30dd77c7",
         intel: "87f7ad14052a213d4fd80431ceaae4df6e843f0052fe78a50d983235ede2b844"

  url "https://github.com/mg-chao/snow-apps/releases/download/v#{version}_snow-shot/snow-shot-#{version}-macos-#{arch}-homebrew.tar.gz"
  name "Snow Shot"
  desc "Screenshot and screen recording application"
  homepage "https://snowshot.top/"

  depends_on macos: :sequoia

  app "Snow Shot.app"
  # Installer scripts run before app artifacts and preserve HOME and Keychain access.
  installer script: {
    executable:   "/bin/bash",
    args:         [staged_path.join("prepare-snow-shot-homebrew.sh"),
                   staged_path.join("snow-shot-#{version}-macos-#{arch}.dmg"),
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
