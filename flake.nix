{
  description = "A NixOS flake for my daily driver";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          # ./configuration.nix
          ./hosts/thinkpad/thinkpad.nix
        ];
      };
      nixosConfigurations.batavia = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # ./configuration.nix
          ./hosts/batavia/batavia.nix
        ];
      };
      nixosConfigurations.alexandria = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          # ./configuration.nix
          ./hosts/alexandria/alexandria.nix
        ];
      };
    };
}
