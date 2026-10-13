{ inputs, config, ... }:
let
  dataDir = "${config.home.homeDirectory}/services";
in {
  imports = [ inputs.quadlet-nix.homeManagerModules.quadlet ];

  systemd.user.tmpfiles.rules = [
    "d ${dataDir}/navidrome/data 0750 - - -"
    "d ${dataDir}/gitore 0750 - - -"
    "d ${dataDir}/fusion 0750 - - -"
    "d ${dataDir}/forgejo 0750 - - -"
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

    containers.fusion = {
      autoStart = true;
      containerConfig = {
        image = "ghcr.io/0x2e/fusion:latest";
        publishPorts = [ "127.0.0.1:8095:8080" ];
        autoUpdate = "registry";
        volumes = [
          "${dataDir}/fusion:/data"
        ];
        environments = {
          FUSION_ALLOW_EMPTY_PASSWORD = "true";
          FUSION_TRUSTED_PROXIES = "127.0.0.1";
        };
      };
      serviceConfig = {
        Restart = "always";
        RestartSec = "10";
      };
    }; 

    containers.forgejo = {
      autoStart = true;
      containerConfig = {
        image = "codeberg.org/forgejo/forgejo:15-rootless";
        userns = "keep-id";
        volumes = [ 
          "${dataDir}/forgejo:/var/lib/gitea" 
          "/etc/localtime:/etc/localtime:ro"
        ];
        publishPorts = [
          "127.0.0.1:8300:3000"
          "2222:22"
        ];
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

    containers.suwayomi = {
      autoStart = true;
      containerConfig = {
        image = "ghcr.io/suwayomi/suwayomi-server:stable";
        publishPorts = [ "127.0.0.1:4567:4567" ];
        userns = "keep-id";
        volumes = [ "/mnt/internal/readers:/home/suwayomi/.local/share/Tachidesk" ];
        environments = {
          TZ = "America/New_York";
          DOWNLOAD_AS_CBZ = "true";
        };
      };
      serviceConfig.TimeoutStartSec = "900";
    };
  };

  home.stateVersion = "25.05";
}
