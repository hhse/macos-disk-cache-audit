---
name: macos-disk-cache-audit
description: Audit macOS disk usage, classify caches and data by deletion risk, and clean only explicitly approved regenerable caches. Use for low-disk diagnosis, cache-junk questions, or safe macOS cleanup planning.
metadata:
  short-description: Safely audit and clean macOS disk caches
---

# macOS Disk Cache Audit

Use this workflow to answer “what can I delete?” without turning a diagnosis into an unbounded cleanup.

## Safety contract

- Treat inspection, diagnosis, and “what is using space?” as read-only requests.
- Delete only after the user explicitly confirms the proposed targets. General approval to clean a previously listed group may cover that exact group, not newly discovered items.
- Never delete a home directory, workspace root, whole cache parent, `~/Library`, `~/Library/Application Support`, or a glob. Use exact absolute paths.
- Do not silently escalate with `sudo`. If macOS protects a target, report it and let the user decide how to authorize removal.
- Do not read file contents or expose secrets. Directory names and aggregate sizes are enough.
- A cache is regenerable, not free. State what becomes slower or must be downloaded again.

## Workflow

1. Run the read-only audit:

   ```bash
   bash scripts/audit-disk.sh
   ```

   Add `--deep` when top-level home usage is also needed. The script never deletes files.

2. Read [references/risk-catalog.md](references/risk-catalog.md) before classifying paths that are not already covered by the audit output.

3. Check whether the owning app is running before recommending app-specific cache deletion. For simulators, verify that they are shut down. Do not close applications or shut down devices without permission.

4. Report the findings with the current free space and a compact table:

   | Candidate | Size | Class | Consequence | Recommendation |
   |---|---:|---|---|---|

   Use these classes:

   - `REGENERABLE`: generated cache with no persistent user content.
   - `CONDITIONAL`: removable only when a tool/device is no longer used.
   - `USER DATA`: documents, app state, messages, simulator state, backups, or downloads.
   - `SYSTEM-PROTECTED`: requires administrator authorization or must remain in place.

5. When cleanup is authorized, repeat the exact-target checks:

   - Resolve and display every absolute target.
   - Recalculate its size and record `df -h /System/Volumes/Data`.
   - Confirm the target still has the expected meaning and is in the confirmed scope.
   - Prefer the tool’s own cache-clean command. Otherwise use `rm -r -- '/absolute/exact/path'`.
   - Never use `rm -rf`, wildcards, or command-line variables that are unresolved or broader than the verified target.

6. Verify the result rather than assuming success:

   - Check that each authorized target is gone.
   - Run `df -h /System/Volumes/Data` again.
   - Report actual space gained, failed targets, and anything left untouched.

## Deletion boundaries

- `~/Library/Application Support`, `~/Library/Containers`, and `~/Library/Group Containers` contain application state. Never recommend deleting them wholesale.
- `~/Downloads`, `~/Documents`, `~/Desktop`, `~/.Trash`, Xcode Archives, and backup folders contain user files or artifacts. Surface them for review, but do not classify them as cache.
- Simulator devices under `~/Library/Developer/CoreSimulator/Devices` contain installed apps and data. Delete a device only after the user selects it or explicitly agrees to lose that data.
- iOS DeviceSupport directories are regenerable but tied to physical-device debugging. Mark them `CONDITIONAL`, not generally safe.
- Playwright browsers and Whisper models often live in cache directories but are functional dependencies. Keep them unless the user no longer needs those tools.
- `/private/var/folders`, `/private/var/db`, and other macOS-managed temporary data should not be manually deleted.

## Special cases

`/Library/Developer/CoreSimulator/Caches/dyld` is a regenerable shared simulator cache and does not contain simulator app data. It is system-protected. Clearing it frees space until the next simulator use, which rebuilds it. Do not run `simctl runtime dyld_shared_cache update --force` as a cleanup substitute because it immediately recreates the cache.

APFS free-space reporting can change after deletion because clones, sparse files, snapshots, and purgeable storage are involved. Report the measured before/after difference without claiming exact physical block accounting.

## Final response

Lead with the amount that can be reclaimed and the amount actually reclaimed. Keep warnings next to the affected item. Mention when caches will regenerate and when a tool or simulator will be slower on its next run.
