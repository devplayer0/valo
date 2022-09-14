{
  description = "Valorant store checker";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    poetry2nix.url = "github:nix-community/poetry2nix";
  };

  outputs = { self, nixpkgs, flake-utils, devshell, poetry2nix }:
  let
    inherit (nixpkgs.lib) composeManyExtensions;
    inherit (flake-utils.lib) eachDefaultSystem;
  in
  {
    overlays = rec {
      valorant-store = composeManyExtensions [
        poetry2nix.overlay
        (final: prev: {
          valorant-store = prev.poetry2nix.mkPoetryApplication {
            projectDir = ./.;
            meta.mainProgram = "valo";
          };
        })
      ];
      default = valorant-store;
    };
  } // (eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          devshell.overlay
          self.overlays.default
        ];
      };
    in
    {
      devShells.default = pkgs.devshell.mkShell {
        packages = with pkgs; [
          poetry
          (pkgs.poetry2nix.mkPoetryEnv {
            projectDir = ./.;
          })
        ];
      };

      packages = rec {
        inherit (pkgs) valorant-store;
        default = valorant-store;
      };

      apps = rec {
        inherit (pkgs) valorant-store;
        default = valorant-store;
      };
    }));
}
