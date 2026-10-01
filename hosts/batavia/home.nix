{ inputs, config, ... }:
let
  dataDir = "${config.home.homeDirectory}/services";
in {
  imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];

  systemd.user.tmpfiles.rules = [
    "d ${dataDir}/navidrome/data 0750 - - -"
  ];

  virtualisation.quadlet = {
    containers.glances = {
      autoStart = true;
      containerConfig = {
	image = "docker.io/nicolargo/glances:latest";
	publishPorts = [ "127.0.0.1:61208:61208" ];
        networks = [ "host" ];
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

    containers.navidrome = {
      autoStart = true;
      containerConfig = {
        image = "docker.io/deluan/navidrome:latest";
	userns = "keep-id";
	publishPorts = [ "127.0.0.1:4533:4533" ];
	autoUpdate = "registry";
	volumes = [
	  "${dataDir}/navidrome/data:/data"
	  "/mnt/internal/music:/music:ro"
	];
	environments = {
	  ND_BASEURL = "https://music.lab.rdrachmanto.dev";
	};
      };
      serviceConfig = {
        Restart = "always";
	RestartSec = "10";
      };
    };

    containers.gitore = {
      autoStart = true;
      containerConfig = {
        image = "codeberg.org/kallisti5/gitore:v0.3.0";
	userns = "keep-id";
	publishPorts = [ "127.0.0.1:3333:8000" ];
	autoUpdate = "registry";
	volumes = [
	  "/mnt/internal/repos:/git"
	];
	environments = {
	  SCAN_PATH = "/git";
	  BIND_ADDRESS = "[::]:8000";
	  DB_STORE = "/tmp/rgit.db";
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
