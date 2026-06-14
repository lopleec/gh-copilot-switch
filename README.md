# GitHub Copilot LLM Switch

A native macOS SwiftUI app for switching the model configuration used by GitHub Copilot CLI.

It lets you store multiple BYOK model profiles, activate exactly one at a time, and write the selected profile into your shell startup file with the correct syntax for `zsh` / `bash` or `fish`.

## Features

- Native macOS SwiftUI interface with sidebar + detail layout
- Multiple saved Copilot provider profiles
- Single active profile at a time
- Managed shell-file writing for:
  - `~/.zshrc`
  - `~/.bash_profile`
  - `~/.config/fish/config.fish`
  - any custom startup file path
- Shell syntax support:
  - POSIX `export`
  - Fish `set -gx`
- API keys stored in Keychain
- Bilingual UI:
  - Simplified Chinese
  - English
- Config preview before applying
- Lightweight automated tests for settings, localization, and shell block generation

## What It Writes

When a profile is activated, the app writes a managed block containing:

```sh
COPILOT_PROVIDER_BASE_URL
COPILOT_PROVIDER_API_KEY
COPILOT_PROVIDER_TYPE
COPILOT_MODEL
```

Only the block owned by this app is replaced. Other shell configuration stays untouched.

## Requirements

- macOS 14 or later
- Xcode 16 / Swift 6.2 toolchain

## Build And Run

This project is a SwiftPM-based macOS app.

### Build

```bash
swift build
```

### Run

```bash
./script/build_and_run.sh
```

### Verify launch

```bash
./script/build_and_run.sh --verify
```

### Run tests

```bash
swift test
```

## How It Works

1. Create one or more provider profiles in the app.
2. Choose the target shell file and shell syntax in Settings.
3. Activate a profile.
4. The app writes a managed block into the configured shell startup file.
5. Reopen Terminal before launching `copilot` so the new environment variables are loaded.

## Security Notes

- API keys are stored in the macOS Keychain, not in the JSON profile store.
- The selected shell file path is configurable, so be deliberate about where the managed block is written.
- If you change the target shell file, re-apply the active profile once so the managed block moves to the new file.

## Project Structure

```text
App/         App entry point and scene wiring
Models/      Value models and validation
Services/    Keychain, shell-file writing, persistence services
Stores/      App state and coordination logic
Support/     Localization, settings, constants, helpers
Views/       SwiftUI screens and components
Tests/       Unit tests
script/      Build and launch helper
```

## Architecture Notes

- Shared app preferences are centralized in `AppSettingsStore`.
- Profile lifecycle and activation logic live in `ProfilesStore`.
- Shell writing is isolated in `ShellEnvironmentService`.
- Localization is handled by `AppLocalizer`.

## Reference

This app is based on GitHub Copilot CLI BYOK model configuration:

- [GitHub Docs: Use BYOK models](https://docs.github.com/zh/copilot/how-tos/copilot-cli/customize-copilot/use-byok-models)
