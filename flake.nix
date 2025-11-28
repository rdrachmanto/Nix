{
  description = "A NixOS flake for my daily driver";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgsForPackages = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}."janet-lsp" = pkgsForPackages.callPackage ./wrappers/janet-lsp.nix { };
      
      nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs self; };
        modules = [
          ./configuration.nix
        ];
      };
    };
}
