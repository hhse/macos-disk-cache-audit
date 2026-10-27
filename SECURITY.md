# Security and privacy

## Data handling

The audit script is local and read-only. It does not read file contents, send telemetry, make network requests, or upload paths.

The Skill may inspect directory names, aggregate sizes, process state, volume usage, simulator state, and Time Machine snapshot metadata. Treat terminal output as local diagnostic data and review it before publishing logs or screenshots.

## Safe use

- Never paste passwords, API tokens, private keys, or personal file contents into an issue.
- Confirm exact absolute paths before any deletion.
- Do not run elevated commands supplied by an untrusted source.
- Keep backups of important projects, device data, and archives.

## Reporting a security issue

Use GitHub’s private security advisory flow for vulnerabilities involving unsafe deletion behavior, command injection, secret exposure, or unexpected network activity.
