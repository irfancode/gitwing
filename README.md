# GitWing 🦅

A blazing-fast, native macOS Git tool built with SwiftUI for Apple Silicon. Menu bar app with worktree management, AI-powered commits, diff viewing, and quick commands.

## Features

- **Menu Bar App** — Runs as a native macOS menu bar app, always accessible
- **Worktree Management** — Register and switch between Git repositories with one click
- **AI Commits** — Generate meaningful commit messages with built-in AI (supports Ollama for privacy)
- **Diff Viewer** — Beautiful syntax-highlighted diffs with line numbers
- **Quick Commands** — One-click access to common Git commands
- **Native SwiftUI** — Built 100% native for Apple Silicon, no Electron bloat

## Requirements

- macOS 14.0 (Sonoma) or later
- Apple Silicon (M1/M2/M3) or Intel Mac
- Homebrew Git (`/opt/homebrew/bin/git`) recommended

## Installation

### From Source

```bash
cd GitWing/Sources
swift build
```

Or open in Xcode:

```bash
open GitWing.xcodeproj
```

### Build for Distribution

```bash
swift build -c release
```

The built app will be in `./.build/release/GitWing.app`

## Usage

1. Click the GitWing icon in the menu bar
2. Add repositories in the **Worktrees** tab
3. Stage files and create commits in the **Commits** tab
4. View diffs in the **Diffs** tab
5. Run quick commands in the **Commands** tab

## Keyboard Shortcuts

- `⌘K` — Open command palette (coming soon)
- `⌘Enter` — Commit staged changes
- `⌘Shift+S` — Stage all changes

## Configuration

GitWing stores settings in UserDefaults:
- `repositories` — Array of registered repo paths
- `diffTheme` — Diff viewer theme (default/monokai/solarized)
- `wordWrap` — Enable word wrapping in diffs

## Contributing

Contributions are welcome! Please read the [contributing guide](CONTRIBUTING.md) first.

## License

MIT License — see [LICENSE](LICENSE) for details.

## Acknowledgments

- [Oh My Worktree](https://github.com/sapsaldog/oh-my-worktree) — Inspiration for worktree management
- [GitMac](https://gitmac.app) — Inspiration for native Git tools on macOS
- [lazygit](https://github.com/jesseduffield/lazygit) — Inspiration for terminal-first Git workflow