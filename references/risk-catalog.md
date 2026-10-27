# macOS disk cleanup risk catalog

Read this catalog when a candidate is not fully described by the audit output. Paths use `~` for the current user’s home directory.

## REGENERABLE

These paths are generated caches. Deleting them does not remove the associated app, project source, account, or simulator device, but first use may be slower and network downloads may recur.

| Path | Consequence and prerequisites |
|---|---|
| `~/Library/Developer/Xcode/UserData/Previews` | Xcode SwiftUI preview cache. Quit Xcode before removal; previews rebuild. |
| `~/Library/Developer/Xcode/UserData/IB Support` | Interface Builder simulator support cache. Quit Xcode before removal; rebuilds when needed. |
| `~/Library/Developer/Xcode/DerivedData` | Build products and indexes. Quit Xcode if possible; the next build is slower. |
| `~/Library/Developer/Xcode/DerivedData/*/Build/Intermediates.noindex` | Build intermediates. Project-level cleanup can be used instead of deleting all DerivedData. |
| `/Library/Developer/CoreSimulator/Caches/dyld` | Generated simulator shared cache. System-protected; recreated during simulator use. |
| `~/.npm/_cacache` | npm downloaded package cache. Re-downloaded as needed; offline installs may fail. |
| `~/.npm/_npx` | Temporary packages run through `npx`. Re-downloaded as needed. |
| `~/.cache/uv` | uv package/build cache. Re-downloaded as needed. |
| `~/Library/Caches/Homebrew` | Homebrew downloads and cached bottles. `brew cleanup` is preferred. |
| `~/Library/Caches/pip` | pip HTTP/wheel cache. Re-downloaded as needed. |
| `~/Library/Caches/Yarn` | Yarn package cache. Use the package manager’s own clean command when available. |
| `~/.cache/yarn` | Yarn package cache on installations using XDG paths. |
| `~/.gradle/caches` | Gradle dependency/build cache. Projects redownload dependencies and rebuild. |
| `~/.cargo/registry/cache` | Downloaded Cargo crates. Use `cargo cache` tooling or the exact cache subdirectory. |

## CONDITIONAL

These items can be large and technically reproducible, but deleting them changes a working environment or removes state that may be expensive to recreate.

| Path | Why it is conditional |
|---|---|
| `~/Library/Developer/CoreSimulator/Devices` | Contains each simulator’s installed apps, settings, and data. Remove only selected, unused devices. |
| `~/Library/Developer/Xcode/iOS DeviceSupport` | Debug symbols for physical devices on specific iOS versions. Re-downloaded when needed. |
| `/Library/Developer/CoreSimulator/Volumes` | Installed simulator runtime images. Needed to build/run for those iOS versions. |
| `~/Library/Caches/ms-playwright` | Playwright browser binaries. Browser automation fails until reinstalled. |
| `~/.cache/whisper` | Local Whisper model files. Transcription requires re-downloading the model. |
| `~/Library/pnpm/store` and `~/.pnpm-store` | pnpm content-addressable package store. Existing projects may depend on it. |
| `~/go/pkg/mod/cache` | Go module download cache. Re-downloaded during builds. |
| `~/Library/Logs` | Diagnostic history. Useful for troubleshooting recent incidents. |
| App-specific `update`, `Cache`, or `crx_cache` folders inside `~/Library/Application Support` | Often safe after an update, but ownership and format vary. Prefer an in-app cleanup command if available. |

## USER DATA

Do not call these “cache junk.” Review only when the user explicitly asks to manage the content.

| Path | Contents |
|---|---|
| `~/Downloads`, `~/Desktop`, `~/Documents` | Personal files, installers, images, source material. |
| `~/.Trash` | Deleted user files awaiting removal. Empty only with explicit permission. |
| `~/Library/Application Support` | Application databases, profiles, account state, local media, and downloads. |
| `~/Library/Containers` | Sandboxed app state, including chat history and app documents. |
| `~/Library/Group Containers` | Shared app/group data. |
| `~/Library/Developer/Xcode/Archives` | Signed archives and dSYMs used for distribution or crash symbolication. |
| `~/Library/Developer/Xcode/UserData/Provisioning Profiles` | Provisioning profiles and signing state. |
| `~/theos.backup.*` and other timestamped backups | User-created recovery data. Never infer that a backup is disposable. |

## SYSTEM-PROTECTED

Do not manually delete these as a routine cleanup.

| Path | Reason |
|---|---|
| `/private/var/folders` | Per-user temporary and cache areas managed by macOS. |
| `/private/var/db` | System databases and service state. |
| `/var/log` and `/private/var/log` | System logs; use supported log-management tools if necessary. |
| APFS local Time Machine snapshots | Report with `tmutil listlocalsnapshots /`; snapshot removal is a separate storage decision. |
| `/System` and protected `/Library` state | Protected by macOS and not general cleanup targets. |

## Commands and interpretation

Useful read-only commands:

```bash
df -h /System/Volumes/Data
du -x -h -d 1 "$HOME" 2>/dev/null | sort -hr | head -n 30
pgrep -fl '/Xcode.app/Contents/MacOS/Xcode|/Simulator.app/Contents/MacOS/Simulator'
xcrun simctl list devices
tmutil listlocalsnapshots /
```

Do not use a generic `du` result as proof that a directory is disposable. A directory is deletable only when its ownership, purpose, and regeneration path are known.
