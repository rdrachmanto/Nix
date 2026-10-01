{ inputs, config, ... }:
let
  inherit (config.virtualisation.quadlet) networks;
in {
  imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];

  virtualisation.quadlet = {
    # networks.web = {
    #   networkConfig.subnets = [ "10.89.10.0/24" ];
    # };

    containers.glances = {
      autoStart = true;
      containerConfig = {
	image = "nicolargo/glances:latest";
	publishPorts = [ "127.0.0.1:61208:61208" ];
        networks = [ networks.web.ref ];
        autoUpdate = "registry";
	volumes = [
	  "/run/user/1000/podman/podman.sock:/run/user/1000/podman/podman.sock:ro"
	];
	environments = {
	  GLANCES_OPT = "-w";
	};
      };
      serviceConfig = {
        Restart = "always";
	RestartSec = "10";
      };
    }; 
  };

  home.stateVersion = "25.05";
}
