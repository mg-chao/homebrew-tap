cask "snow-shot" do
  version "1.2.2"
  sha256 "982722ce39ac3509f8fe65a76f2f4320310610865110bf6745beaad63b5fc253"

  url "https://github.com/mg-chao/snow-apps/releases/download/v#{version}_snow-shot/snow-shot-#{version}-macos-arm64-homebrew.tar.gz"
  name "Snow Shot"
  desc "Screenshot and screen recording application"
  homepage "https://snowshot.top/"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "Snow Shot.app"

  # Third-party Ruby hooks preserve the desktop user's HOME and Keychain access.
  preflight do
    system_command "/bin/bash",
                   args:         [staged_path.join("prepare-snow-shot-homebrew.sh"),
                                  staged_path.join("snow-shot-#{version}-macos-arm64.dmg"),
                                  staged_path.join("Snow Shot.app")],
                   must_succeed: true,
                   print_stdout: true,
                   print_stderr: true
  end

  caveats <<~EOS
    Snow Shot reuses a signing identity in your login Keychain. The first install
    may request Keychain access. Grant Screen Recording and Accessibility when
    macOS requests them. Local signing does not provide Apple notarization.
    Keep ~/Library/Application Support/Snow Shot/Installer and its Keychain
    identity across upgrades and reinstalls. Use the same installing account.
  EOS
end
