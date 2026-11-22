cask "snow-shot" do
  arch arm: "arm64", intel: "x86_64"

  version "1.6.3"
  sha256 arm:   "a521debad13cbac5da1a981c1779cc07966d31fe67a407e422272b1309a6a6e2",
         intel: "cc0239ab7d669e48d908b98e40e85a4a4109bc88f0d7e37bc4c32350ac91dcdf"

  url "https://github.com/mg-chao/snow-shot/releases/download/v#{version}_snow-shot/snow-shot-#{version}-macos-#{arch}-homebrew.tar.gz"
  name "Snow Shot"
  desc "Screenshot and screen recording application"
  homepage "https://snowshot.top/"

  depends_on macos: :sequoia

  app "Snow Shot.app"
  # Verify the publisher signature before Homebrew places the unchanged app.
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
  # Keep user data and any legacy installer state.
  uninstall quit:   "com.snowshot.snow_shot",
            script: {
              executable: "/bin/rm",
              args:       ["-rf", "--", "#{staged_path}/Snow Shot.app"],
              sudo:       false,
            }

  caveats <<~EOS
    Snow Shot preserves the project signature shared by DMG and script installs.
    No local signing key or Keychain access is needed. First installation or
    migration from older ad-hoc/local signatures may require granting Screen
    Recording and Accessibility again. Self-signing is not Apple notarization.
    Use installers from the current release; older scripts re-sign applications.
  EOS
end
