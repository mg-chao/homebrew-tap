import unittest
from patch_casks import patch


def upstream(dmg='snow-shot-#{version}-macos-#{arch}.dmg', app='Snow Shot.app', mini=False):
    edition = ',\n                                  "mini"' if mini else ''
    return '''cask "example" do
  version "9.8.7"
  sha256 "upstream-checksum"
  app "''' + app + '''"

  # Third-party Ruby hooks preserve the desktop user's HOME and Keychain access.
  preflight do
    system_command "/bin/bash",
                   args:         [staged_path.join("prepare-snow-shot-homebrew.sh"),
                                  staged_path.join("''' + dmg + '''"),
                                  staged_path.join("''' + app + '''")''' + edition + '''],
                   must_succeed: true,
                   print_stdout: true,
                   print_stderr: true
  end
end
'''


class MigrationTests(unittest.TestCase):
    def test_preserves_upstream_version_checksum_and_architecture(self):
        source = upstream()
        result = patch(source, 'snow-shot.rb')
        self.assertIn('version "9.8.7"', result)
        self.assertIn('sha256 "upstream-checksum"', result)
        self.assertIn('snow-shot-#{version}-macos-#{arch}.dmg', result)
        self.assertIn('installer script:', result)
        self.assertIn('uninstall quit: "com.snowshot.snow_shot"', result)
        self.assertNotIn('preflight do', result)
        self.assertNotIn('print_stdout:', result)
        self.assertEqual(patch(result, 'snow-shot.rb'), result)

    def test_mini_keeps_edition_and_identity(self):
        result = patch(upstream('snow-shot-mini-#{version}-macos-arm64.dmg', 'Snow Shot Mini.app', True), 'snow-shot-mini.rb')
        self.assertIn('"mini"],', result)
        self.assertIn('com.snowshot.snow_shot_mini', result)

    def test_changed_script_fails_closed(self):
        with self.assertRaises(ValueError):
            patch(upstream().replace('prepare-snow-shot-homebrew.sh', 'different.sh'), 'snow-shot.rb')

    def test_unknown_cask_hook_fails_closed(self):
        with self.assertRaises(ValueError):
            patch(upstream(), 'other.rb')

    def test_upstream_migration_is_preserved(self):
        source = 'cask "example" do\n  preflight_steps do\n    touch "state"\n  end\nend\n'
        self.assertEqual(patch(source, 'snow-shot.rb'), source)


if __name__ == '__main__':
    unittest.main()
