cask "snow-shot" do
  arch arm: "arm64", intel: "x86_64"

  version "1.6.0"
  sha256 arm:   "89097043f9b63bea0064c7a4391649152ec0f01e3e7a024f2cdaa344245e1497",
         intel: "7769643119454eb639fafe5740bde4968723c47143c5b92cdbd9953b22e6ee07"

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
  uninstall script: {
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
