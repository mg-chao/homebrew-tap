cask "snow-shot" do
  arch arm: "arm64", intel: "x86_64"

  version "1.2.6"
  sha256 arm:   "67e93b9d750066f8fbd66c435be1f727017166bd667c543947d11e3b630c64f6",
         intel: "6ddd4523c590599c8c5a883737cd062b5fbcbdb2b042ca64cf45fd4d182c5271"

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
