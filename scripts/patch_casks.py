#!/usr/bin/env python3
"""Reapply the narrowly scoped Snow Shot installer migration to upstream casks."""
import re
from pathlib import Path

HOOK = re.compile(
    r'  # Third-party Ruby hooks preserve the desktop user\'s HOME and Keychain access\.\n'
    r'  preflight do\n'
    r'    system_command "/bin/bash",\n'
    r'(?P<options>.*?\n)'
    r'  end\n', re.DOTALL,
)
IDENTITIES = {
    "snow-shot.rb": "com.snowshot.snow_shot",
    "snow-shot@beta.rb": "com.snowshot.snow_shot",
    "snow-shot-mini.rb": "com.snowshot.snow_shot_mini",
}


def patch(text: str, filename: str) -> str:
    if not re.search(r'^  preflight do$', text, re.MULTILINE):
        if re.search(r'^  (?:postflight|uninstall_preflight|uninstall_postflight) do$', text, re.MULTILINE):
            raise ValueError(f"{filename}: unexpected deprecated hook")
        return text  # Upstream already migrated; preserve its implementation.
    if filename not in IDENTITIES or len(HOOK.findall(text)) != 1:
        raise ValueError(f"{filename}: preparation hook changed; manual review required")
    match = HOOK.search(text)
    options = match['options']
    if not re.fullmatch(
        r'                   args:         \[staged_path\.join\("prepare-snow-shot-homebrew\.sh"\),\n'
        r'                                  staged_path\.join\("snow-shot[^"\n]*\.dmg"\),\n'
        r'                                  staged_path\.join\("Snow Shot(?: Mini)?\.app"\)'
        r'(?:,\n                                  "mini")?\],\n'
        r'                   must_succeed: true,\n'
        r'                   print_stdout: true,\n'
        r'                   print_stderr: true\n', options,
    ):
        raise ValueError(f"{filename}: preparation arguments changed; manual review required")
    if '  installer ' in text or '  uninstall ' in text:
        raise ValueError(f"{filename}: existing installer/uninstall needs manual review")
    lines = options.splitlines()
    lines = [line[15:] for line in lines]
    lines[-1] += ','
    replacement = (
        '  # Installer scripts run before app artifacts and preserve HOME and Keychain access.\n'
        '  installer script: {\n'
        '    executable:   "/bin/bash",\n' + '\n'.join(lines) + '\n'
        '  }\n\n'
        '  # Homebrew removes the app; retain the signing identity and user data.\n'
        f'  uninstall quit: "{IDENTITIES[filename]}"\n'
    )
    result = text[:match.start()] + replacement + text[match.end():]
    if re.search(r'^  (?:preflight|postflight|uninstall_preflight|uninstall_postflight) do$', result, re.MULTILINE):
        raise ValueError(f"{filename}: unexpected deprecated hook")
    return result


if __name__ == '__main__':
    files = sorted(Path('Casks').glob('*.rb'))
    if not files:
        raise SystemExit('No upstream casks found')
    # Validate every transformation before writing any file.
    updates = [(path, patch(path.read_text(), path.name)) for path in files]
    for path, text in updates:
        path.write_text(text)
