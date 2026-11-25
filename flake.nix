{
  description = "sing-box-proxy — controller for a sing-box SOCKS proxy (on/off/status/refresh/gen/run)";

  # The rev the host repository pins, so a standalone `nix build` here and the
  # host build use the same nixpkgs. Consumers usually pass
  # `inputs.nixpkgs.follows = "nixpkgs"` and ignore this pin.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/2786a2a72088ecf32aea5b3ec52099e6a7cff78f";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.callPackage ./default.nix { };
          sing-box-proxy = self.packages.${system}.default;
        }
      );

      overlays.default = final: _prev: {
        sing-box-proxy = final.callPackage ./default.nix { };
      };

      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
