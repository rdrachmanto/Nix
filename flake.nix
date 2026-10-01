{
  description = "A NixOS flake for my daily driver";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    agenix.url = "github:ryantm/agenix";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
  };

  outputs = { self, nixpkgs, home-manager, quadlet-nix, ... }@inputs:
    let
      system = "x86_64-linux";
    in {
      nixosConfigurations.thinkpad = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/thinkpad/thinkpad.nix
        ];
      };
      nixosConfigurations.batavia = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/batavia/batavia.nix
          inputs.agenix.nixosModules.default
	  quadlet-nix.nixosModules.quadlet
	  home-manager.nixosModules.home-manager
	  {
            home-manager.extraSpecialArgs = { inherit inputs; };
	    home-manager.users.rd = import ./hosts/batavia/home.nix;
	  }
        ];
      };
      nixosConfigurations.alexandria = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/alexandria/alexandria.nix
        ];
      };
    };
}
