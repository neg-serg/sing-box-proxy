# sing-box-proxy

Controller for a [sing-box](https://sing-box.sagernet.org/) SOCKS proxy that
runs as a systemd user unit. One binary, `proxy`: it builds the sing-box config
from node URIs and subscription lines, generates the bootstrap config, starts
and stops the unit, reports status, and validates the result by actually
connecting through the proxy.

This was a bash helper with three embedded Python programs in a host NixOS
repository. The port keeps its CLI, its stdout/stderr split, the messages it
prints, the exact JSON it emits and the validation behaviour; the repository
splits so the crate owns its own packaging.

## Commands

| command | what it does |
| --- | --- |
| `proxy` / `proxy status` | endpoint, config, unit state and the SOCKS check |
| `proxy on` / `proxy start` | stop `xray.service` if active, generate the config, start the unit (falls back to a detached `sing-box` run), then validate |
| `proxy off` / `proxy stop` | stop the unit (or `pkill` the legacy process) and bring `xray.service` back |
| `proxy gen` / `proxy bootstrap` | regenerate the bootstrap config only |
| `proxy refresh` | probe every node, keep the reachable ones, rewrite the config, restart the unit |
| `proxy run <cmd...>` / `proxy exec <cmd...>` | run a command with `ALL_PROXY`/`HTTPS_PROXY`/`HTTP_PROXY` pointed at the SOCKS endpoint |

Unknown commands print `Usage: proxy {on|off|status|refresh|gen|run <cmd...>}`
on stderr and exit 1.

## Environment

Every path has a default; the `PROXY_*` variables exist so the tool can be
tested without touching the live config or the real secrets.

| variable | default |
| --- | --- |
| `PROXY_CONFIG` | `$HOME/.config/sing-box-trojan/config.json` |
| `PROXY_LOG` | `/tmp/sing-box-trojan.log` |
| `PROXY_SECRET` | `/run/secrets/proxy-fallback` (fallback node / subscription lines) |
| `PROXY_LAN_SECRET` | `/run/secrets/proxy-lan` (LAN listener block) |
| `VALIDATE_TMP`, `PROXY_VALIDATE_TMP` | `/tmp/proxy-validate` |

Secrets are read at runtime from those files; nothing is embedded in the
binary.

## Requirements

Linux with a `sing-box-proxy.service` user unit and `sing-box` on `PATH`. The
binary also shells out to `systemctl --user`, `curl`, `pgrep`/`pkill`, `ss`,
`setsid` and `nix`-free helpers; stopping `xray.service` uses `sudo -n` when
available and falls back to `pkill`. The SOCKS endpoint is `127.0.0.1:10808`.

## Build

```sh
nix build          # ./result/bin/proxy
nix flake check    # evaluates the flake and builds the package
cargo build --release
```

The flake exposes `packages.<system>.default`, `overlays.default` (attribute
`sing-box-proxy`) and a `formatter`.

Consumed from a NixOS flake as:

```nix
inputs.sing-box-proxy = {
  url = "github:neg-serg/sing-box-proxy";
  inputs.nixpkgs.follows = "nixpkgs";
};
# ...
pkgs.sing-box-proxy
```

The binary is named `proxy` (`meta.mainProgram`), so a consumer can link
`~/.local/bin/proxy` at `lib.getExe' pkgs.sing-box-proxy "proxy"`.

## Scope

- Linux only: systemd user units, `/run/secrets`, `setsid`.
- No test suite. The host repository removed its Rust test trees (including the
  golden fixtures this port was verified against) and this crate came out
  without one; `nix flake check` therefore only builds the package.
- The defaults (`$HOME/.config/sing-box-trojan`, `127.0.0.1:10808`) are the
  author's setup. They are overridable, but this is not a general-purpose
  sing-box front end.
