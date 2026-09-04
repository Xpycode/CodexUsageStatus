# Codex Usage Status

A dockless macOS HUD for displaying Codex usage information.

## Requirements

- Xcode 26 or newer
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (used to generate the Xcode project)

## Getting started

Press **Control–Option–Command–X** to toggle the panel. MousePlus can send this
shortcut from a ring action; a click anywhere else dismisses the panel.

The app reads `~/.codex/auth.json` only in memory to retrieve usage. It stores no
credentials or usage history; sandboxing is disabled because that Codex data path
is user-owned and outside an app container.

This independent utility uses an undocumented Codex usage endpoint that may
change. It never logs or persists the access token or account ID, and labels a
rate-limit window as unavailable rather than guessing its value.

```sh
xcodegen generate
open CodexUsageStatus.xcodeproj
```

Or build from the command line:

```sh
xcodebuild -project CodexUsageStatus.xcodeproj -scheme CodexUsageStatus build
```

## Create a release

```sh
scripts/release.sh 0.1.0
```

This writes `dist/CodexUsageStatus-0.1.0.zip`. Sign and notarize a public
release with your Developer ID; otherwise Gatekeeper will warn users. GitHub
Actions runs the build and tests for every push and pull request.

## License

MIT. See [LICENSE](LICENSE).

## Layout

- `Sources/App` — application lifecycle and composition
- `Sources/Features` — user-facing feature modules
- `Sources/Shared` — reusable models and services
- `Resources` — asset catalogs and app resources
- `Tests` — unit tests mirroring source modules
