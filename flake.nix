{
  description = "Nix package for Flux, a keyboard-first GTK4/Libadwaita file manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flux-src = {
      url = "github:killown/flux/6479c9060b141c1e56d42e0e8c7279a102de2b32";
      flake = false;
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://erialsan.cachix.org"
    ];
    extra-trusted-public-keys = [
      "erialsan.cachix.org-1:TCJo1GXMp1biAoY2SaghfNK7W4kXGvymlJmJ4cIPNG4="
    ];
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
