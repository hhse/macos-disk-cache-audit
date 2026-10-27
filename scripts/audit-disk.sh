#!/bin/bash

set -u

deep=0
if [ "${1:-}" = "--deep" ]; then
  deep=1
elif [ "$#" -gt 0 ]; then
  printf 'Usage: %s [--deep]\n' "$0" >&2
  exit 2
fi

if [ "$(uname -s)" != "Darwin" ]; then
  printf 'This audit targets macOS.\n' >&2
  exit 1
fi

display_path() {
  case "$1" in
    "$HOME"/*) printf '~%s\n' "${1#"$HOME"}" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

audit_path() {
  risk_class="$1"
  audit_target="$2"
  note="$3"

  if [ ! -e "$audit_target" ]; then
    return
  fi

  audit_size="$(du -sh "$audit_target" 2>/dev/null | awk '{print $1}')"
  [ -n "$audit_size" ] || audit_size='?'
  printf '%-17s\t%8s\t%-55s\t%s\n' \
    "$risk_class" "$audit_size" "$(display_path "$audit_target")" "$note"
}

printf '# macOS Disk Cache Audit\n\n'
printf 'Generated: %s\n' "$(date '+%Y-%m-%d %H:%M:%S %Z')"
printf 'Mode: read-only%s\n' "$([ "$deep" -eq 1 ] && printf ' + deep usage scan')"

printf '\n## Volume\n\n'
df -h /System/Volumes/Data 2>/dev/null || df -h /

printf '\n## Process state\n\n'
if pgrep -f '/Xcode.app/Contents/MacOS/Xcode|/Simulator.app/Contents/MacOS/Simulator' >/dev/null 2>&1; then
  printf 'Xcode or Simulator is running. Do not remove Xcode caches yet.\n'
else
  printf 'Xcode and Simulator are not running.\n'
fi

simctl_bin='/Applications/Xcode.app/Contents/Developer/usr/bin/simctl'
if [ -x "$simctl_bin" ]; then
  booted="$("$simctl_bin" list devices 2>/dev/null | grep 'Booted' || true)"
  if [ -n "$booted" ]; then
    printf 'Booted simulators:\n%s\n' "$booted"
  else
    printf 'No booted simulators detected.\n'
  fi
fi

printf '\n## Candidates\n\n'
printf '%-17s\t%8s\t%-55s\t%s\n' 'CLASS' 'SIZE' 'PATH' 'NOTE'
printf '%-17s\t%8s\t%-55s\t%s\n' '-----------------' '--------' '-------------------------------------------------------' '----'

audit_path 'REGENERABLE' "$HOME/Library/Developer/Xcode/UserData/Previews" 'Quit Xcode; SwiftUI previews cache'
audit_path 'REGENERABLE' "$HOME/Library/Developer/Xcode/UserData/IB Support" 'Quit Xcode; Interface Builder cache'
audit_path 'REGENERABLE' "$HOME/Library/Developer/Xcode/DerivedData" 'Build products; next build is slower'
audit_path 'SYSTEM-PROTECTED' '/Library/Developer/CoreSimulator/Caches/dyld' 'Regenerable; requires admin; returns after use'
audit_path 'REGENERABLE' "$HOME/.npm/_cacache" 'npm package cache; redownloads as needed'
audit_path 'REGENERABLE' "$HOME/.npm/_npx" 'npx temporary packages; redownloads as needed'
audit_path 'REGENERABLE' "$HOME/.cache/uv" 'uv package cache; redownloads as needed'
audit_path 'REGENERABLE' "$HOME/Library/Caches/Homebrew" 'Prefer brew cleanup'
audit_path 'REGENERABLE' "$HOME/Library/Caches/pip" 'pip download cache'
audit_path 'REGENERABLE' "$HOME/Library/Caches/Yarn" 'Yarn cache'
audit_path 'REGENERABLE' "$HOME/.cache/yarn" 'Yarn cache'
audit_path 'REGENERABLE' "$HOME/.gradle/caches" 'Gradle caches; rebuild required'
audit_path 'CONDITIONAL' "$HOME/Library/Caches/ms-playwright" 'Browser automation dependency'
audit_path 'CONDITIONAL' "$HOME/.cache/whisper" 'Whisper model cache'
audit_path 'CONDITIONAL' "$HOME/Library/Developer/Xcode/iOS DeviceSupport" 'Physical-device debug symbols'
audit_path 'CONDITIONAL' "$HOME/Library/Logs" 'Useful diagnostic history'
audit_path 'USER DATA' "$HOME/Library/Developer/CoreSimulator/Devices" 'Simulator apps and state'
audit_path 'USER DATA' "$HOME/Library/Developer/Xcode/Archives" 'Distribution archives and dSYMs'
audit_path 'USER DATA' "$HOME/Library/Application Support" 'Application state; never delete wholesale'
audit_path 'USER DATA' "$HOME/Library/Containers" 'Sandboxed app state; never delete wholesale'
audit_path 'USER DATA' "$HOME/Library/Group Containers" 'Shared app data; never delete wholesale'
audit_path 'USER DATA' "$HOME/Downloads" 'Personal files and installers'
audit_path 'USER DATA' "$HOME/.Trash" 'Deleted user files; explicit approval required'
audit_path 'SYSTEM-PROTECTED' '/Library/Developer/CoreSimulator/Volumes' 'Installed simulator runtimes'
audit_path 'SYSTEM-PROTECTED' '/private/var/folders' 'macOS-managed temporary data'
audit_path 'SYSTEM-PROTECTED' '/private/var/db' 'System databases and service state'

printf '\n## Time Machine snapshots\n\n'
if command -v tmutil >/dev/null 2>&1; then
  tmutil listlocalsnapshots / 2>&1 || true
else
  printf 'tmutil is unavailable.\n'
fi

if [ "$deep" -eq 1 ]; then
  printf '\n## Top home directories\n\n'
  du -x -h -d 1 "$HOME" 2>/dev/null | sort -hr | head -n 30 |
    while IFS= read -r line; do
      line_size="${line%%$'\t'*}"
      line_path="${line#*$'\t'}"
      printf '%8s\t%s\n' "$line_size" "$(display_path "$line_path")"
    done
fi

printf '\nNo files were deleted.\n'
