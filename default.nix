# sing-box-proxy — controller for a sing-box SOCKS proxy.
#
# Packaging only. What the commands do and the environment variables they read
# live in README.md and the module docs in src/.
{
  lib,
  rustPlatform,
}:

rustPlatform.buildRustPackage {
  pname = "sing-box-proxy";
  version = (lib.importTOML ./Cargo.toml).package.version;

  # Keep /result, /target and the flake out of the store copy.
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./Cargo.toml
      ./Cargo.lock
      ./src
    ];
  };

  cargoLock.lockFile = ./Cargo.lock;

  meta = {
    description = "Controller for a sing-box SOCKS proxy (on/off/status/refresh/gen/run)";
    homepage = "https://github.com/neg-serg/sing-box-proxy";
    license = lib.licenses.mit;
    mainProgram = "proxy";
    platforms = lib.platforms.linux;
  };
}
