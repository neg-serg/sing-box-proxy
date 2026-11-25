# sing-box-proxy — working contract

`proxy` is a Rust port of a bash + Python helper that drove a sing-box SOCKS
proxy on one NixOS host. The repository owns the crate and its packaging; host
glue (the systemd user unit, the secrets, the feature flag) stays in the host
configuration, which consumes this flake as an input.

## Rules

- Documentation and code comments are English only. Reply to the maintainer in
  Russian; never write Chinese anywhere.
- Keep the byte-level contract with the previous shell helper: same CLI, same
  stdout/stderr split, same messages, byte-identical generated JSON. Any change
  there is a compatibility change, not a cleanup.
- Paths and endpoints are environment-driven (`PROXY_*`); do not hardcode new
  host paths. The existing defaults are the author's setup and stay overridable.
- No test suite by design: the host repository dropped its Rust test trees and
  this crate was extracted afterwards. Do not re-add fixtures that only exist in
  another repository's history.
- `default.nix` packs only `Cargo.toml`, `Cargo.lock` and `src/`; keep the
  fileset in sync when a file is added to the build.

## Commands

```sh
nix build                    # ./result/bin/proxy
nix flake check              # flake eval + package build
cargo build --release
nix fmt                      # nixfmt through the flake formatter
```

## Commits

`[scope] Imperative subject` without a trailing period; bodies may be Russian.
