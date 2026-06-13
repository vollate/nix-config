# Agent Notes

## Project Commands

- Run Justfile recipes as `just <command>`.
- Do not pass the host name explicitly to `just` recipes such as `deploy`, `build`, `check`, `debug`, `update`, `diff`, `install`, or `test-vm`.
- The `Justfile` reads the target host from the `HOST` environment variable.
- Format this repository with `just fmt`; do not run `nix fmt` or `nixfmt` directly.

Examples:

```bash
just check
just build
just deploy
```
