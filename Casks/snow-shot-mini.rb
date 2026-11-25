cask "snow-shot-mini" do
  version "1.6.5"
  sha256 "1d6036e0db4b268f7efe9e5c03de306d3c87da209b7d8ed6ede3f29d20ae259f"

  url "https://github.com/mg-chao/snow-shot/releases/download/v#{version}_snow-shot/snow-shot-mini-#{version}-macos-arm64-homebrew.tar.gz"
  name "Snow Shot Mini"
  desc "Screenshot and screen recording application"
  homepage "https://snowshot.top/"

  depends_on arch: :arm64
  depends_on macos: :sequoia

  app "Snow Shot Mini.app"
  # Verify the publisher signature before Homebrew places the unchanged app.
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
  # Keep user data and any legacy installer state.
  uninstall quit:   "com.snowshot.snow_shot_mini",
            script: {
              executable: "/bin/rm",
              args:       ["-rf", "--", "#{staged_path}/Snow Shot Mini.app"],
              sudo:       false,
            }

  caveats <<~EOS
    Snow Shot Mini preserves the project signature shared by DMG and script installs.
    No local signing key or Keychain access is needed. First installation or
    migration from older ad-hoc/local signatures may require granting Screen
    Recording and Accessibility again. Self-signing is not Apple notarization.
    Use installers from the current release; older scripts re-sign applications.
  EOS
end
