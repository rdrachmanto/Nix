{
  description = "A NixOS flake for my daily driver";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    lem.url = "github:lem-project/lem";
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
          { nixpkgs.overlays = [ inputs.lem.overlays.default ]; }
          ./configuration.nix
        ];
      };
    };
}
