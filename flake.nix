{
  description = "Nix package for Flux, a keyboard-first GTK4/Libadwaita file manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/0bb2eedc20e4739f29e8045034f2828ad7054f8f";

    flux-src = {
      url = "github:killown/flux/c6147ccee4694f19716684a9b29b6ce029281829";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flux-src,
  }: let
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
    pkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in {
    packages = forAllSystems (system: let
      flux-filemanager = pkgsFor.${system}.callPackage ./package.nix {
        src = flux-src;
      };
    in {
      inherit flux-filemanager;
      default = flux-filemanager;
    });

    # NUR や他の flake から、そのまま pkgs.flux-filemanager を追加できる。
    overlays.default = final: _prev: {
      flux-filemanager = final.callPackage ./package.nix {
        src = flux-src;
      };
    };

    formatter = forAllSystems (system: pkgsFor.${system}.alejandra);
  };
}
