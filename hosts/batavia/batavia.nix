{ config, pkgs, inputs, ... }:
{
  imports = [
    ../../base.nix
    ./hardware-configuration.nix
  ];

  # Set timezone
  time.timeZone = "America/New_York";

  # Set device hostname
  networking.hostName = "rd-batavia";

  environment.systemPackages = with pkgs; [
    inputs.agenix.packages."${system}".default
    podman-compose
    neovim
  ];

  # User groups
  users.groups.git = {};
  users.groups.podman = {};
  users.groups.syncthing = {};
  
  users.users.rd = {
    extraGroups = [ "git" "podman" "syncthing" ];
    linger = true;
    autoSubUidGidRange = true;
  };

  programs.zsh.enable = true;

  # Enable ssh into machine
  services.openssh.enable = true;

  age.secrets = {
    caddy = {
      file = ../../secrets/caddy.age;
      path = "/etc/caddy/Caddyfile";
      owner = "caddy";
      group = "caddy";
      mode = "600";
    };
  };

  services.caddy = {
    enable = true;
    email = "rakandhiya.daanii@gmail.com";
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/porkbun@v0.3.1" ];
      hash = "sha256-ayBJpLRQtQ7YmTLhMM63ECmvPcQwOPWe6VSCCotPbnA=";
    }; 
    globalConfig = ''    
      cert_issuer acme {
        dns porkbun {
          api_key {env.PORKBUN_API_KEY}
          api_secret_key {env.PORKBUN_API_SECRET_KEY}
        }
        resolvers 1.1.1.1 8.8.8.8
      }
    '';
    virtualHosts."lab.rdrachmanto.dev".extraConfig = ''
      root * /mnt/www/planet
      file_server
    '';
    virtualHosts."status.lab.rdrachmanto.dev".extraConfig = ''
      reverse_proxy http://127.0.0.1:3230
    '';
    virtualHosts."monitor.lab.rdrachmanto.dev".extraConfig = ''
      reverse_proxy http://127.0.0.1:61208
    '';
    virtualHosts."music.lab.rdrachmanto.dev".extraConfig = ''
      reverse_proxy http://127.0.0.1:4533
    '';
    virtualHosts."git.lab.rdrachmanto.dev".extraConfig = ''
      reverse_proxy http://127.0.0.1:8300
    '';
    virtualHosts."reader.lab.rdrachmanto.dev".extraConfig = ''
      reverse_proxy http://127.0.0.1:4567
    '';
    virtualHosts."rss.lab.rdrachmanto.dev".extraConfig = ''
      reverse_proxy http://127.0.0.1:8095
    '';
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = [
    config.age.secrets.caddy.path
  ];

  services.dnsmasq = {
    enable = true;
    settings = {
      no-resolv = true;
      server = [ "128.192.0.1" "128.192.0.0" ];
      dns-loop-detect = true;

      interface = "tailscale0";
      bind-dynamic = true;

      local = "/lab.rdrachmanto.dev/";
      address = "/lab.rdrachmanto.dev/100.118.182.21";

      domain-needed = true;
      bogus-priv = true;
    };
  };

  services.syncthing = {
    enable = true;
    user = "syncthing";
    group = "syncthing";
    dataDir = "/var/lib/syncthing"; 
    configDir = "/var/lib/syncthing/.config/syncthing";
    openDefaultPorts = true;
    guiAddress = "0.0.0.0:8384";

    overrideDevices = true;
    overrideFolders = true;

    settings = {
      devices = {
        "rd-x1carbon" = { 
          id = "KGSEPJB-6647H6P-CDFAMMA-AP6QOZ6-3CKTHD4-O5G76I6-AE555ZC-XSMRWAX";
          addresses = [ "tcp://100.111.30.10" ];
        };
      };
      folders = {
        "Documents" = {
          path = "/mnt/internal/shares/Documents";
          devices = [ "rd-x1carbon" ];
          versioning = {
            type = "staggered";
            params = { cleanInterval = "3600"; maxAge = "2592000"; };
          };
        };
        "Research" = {
          path = "/mnt/internal/shares/Research";
          devices = [ "rd-x1carbon" ];
          ignorePerms = false;
          ignorePatterns = [
            "**/.venv"
            "**/node_modules"
            "**/__pycache__"
            "**/target"
            "**/.vscode"
            "**/.idea"
            "**/*.o"
            "**/*.pyc"
          ];
          versioning = {
            type = "staggered";
            params = { cleanInterval = "3600"; maxAge = "2592000"; };
          };
        };
      };
    };
  };

  virtualisation = {
    containers.enable = true;
    quadlet.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultNetwork.settings.dns_enabled = true; # Required for containers under podman-compose to be able to talk to each other.
    };
  };

  virtualisation.oci-containers = {
    backend = "podman";
  };

  networking.firewall.allowedTCPPorts = [ 80 443 4533 9000 8384 8300 4567 ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  system.stateVersion = "25.11";
}
