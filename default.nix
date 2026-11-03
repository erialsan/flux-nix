{
  pkgs ? import <nixpkgs> {},
}: let
  lock = builtins.fromJSON (builtins.readFile ./flake.lock);
  source = lock.nodes."flux-src".locked;
in {
  flux-filemanager = pkgs.callPackage ./package.nix {
    src = pkgs.fetchFromGitHub {
      inherit (source) owner repo rev;
      hash = source.narHash;
    };
  };
}
