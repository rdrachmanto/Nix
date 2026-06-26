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
  ];

  # User groups
  users.groups.git = {};
  users.users.rdrachmanto.extraGroups = [ "git" ];
  users.users.legit.extraGroups = [ "git" ];

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
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/porkbun@v0.3.1" ];
      hash = "sha256-MlKX2obWac+jP4j9UHFMxsY/DRaqw9JCVAdI7erhFwo=";
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
      reverse_proxy http://127.0.0.1:5555
    '';
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = [
    config.age.secrets.caddy.path
  ];

  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "tailscale0";
      bind-dynamic = true;

      local = "/lab.rdrachmanto.dev/";
      address = "/lab.rdrachmanto.dev/100.109.117.96";

      domain-needed = true;
      bogus-priv = true;
    };
  };

  services.gatus = {
    enable = true;
    settings = {
      web.port = 3230;
      endpoints = [
        {
          name = "Portfolio Website";
	  group = "Core";
	  url = "https://rdrachmanto.github.io";
	  interval = "5m";
	  conditions = [
	    "[STATUS] == 200"
	  ];
        }
      ];
    };
  };

  services.glances = {
    enable = true;
  };

  services.legit = {
    enable = true;
    user = "legit";
    group = "legit";
    settings = {
      dirs = {
        static = "${./legit/static}";
        templates = "${./legit/templates}";
      };
      server = {
        port = 5555;
        name = "git.lab.rdrachmanto.dev";
      };
      repo = {
        readme = [ "README.md" "README.org" "README" "README.txt" "readme" ];
        scanPath = "/mnt/repos/";
      };
    };
  };

  services.navidrome = {
    enable = true;
    settings = {
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = "/mnt/music";
      BaseUrl = "https://music.lab.rdrachmanto.dev";
    };
    openFirewall = true;
  };
  
  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        "hosts allow" = "127.0.0.1 100.";
        "hosts deny" = "0.0.0.0/0";
        "guest account" = "nobody";
        "map to guest" = "bad user";
      };
      "Public" = {
        "path" = "/mnt/shares/Public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "rdrachmanto";
        "force group" = "users";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [ 80 443 4533 9000 ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  system.stateVersion = "25.11";
}
