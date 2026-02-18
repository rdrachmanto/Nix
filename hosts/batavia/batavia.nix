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
    miniflux = {
      file = ../../secrets/miniflux.age;
      path = "/etc/nixos/miniflux-admin-credentials";
    };
  };
  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/porkbun@v0.3.1" ];
      hash = "sha256-aVSE8y9Bt+XS7+M27Ua+ewxRIcX51PuFu4+mqKbWFwo=";
    }; 
    globalConfig = ''    
      auto_https prefer_wildcard

      cert_issuer acme {
        dns porkbun {
          api_key {env.PORKBUN_API_KEY}
          api_secret_key {env.PORKBUN_API_SECRET_KEY}
        }
        resolvers 1.1.1.1 8.8.8.8
      }
    '';
    virtualHosts."lab.rdrachmanto.dev".extraConfig = ''
      respond "Hello from caddy!"
    '';
    virtualHosts."status.lab.rdrachmanto.dev".extraConfig = ''
      reverse_proxy http://127.0.0.1:3230
    '';
    virtualHosts."monitor.lab.rdrachmanto.dev".extraConfig = ''
      reverse_proxy http://127.0.0.1:61208
    '';
    virtualHosts."rss.lab.rdrachmanto.dev".extraConfig = ''
      reverse_proxy http://127.0.0.1:3001
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
        {
          name = "RSS Reader";
	  group = "Core";
	  url = "https://rss.lab.rdrachmanto.dev";
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

  services.miniflux = {
    enable = true;
    adminCredentialsFile = config.age.secrets.miniflux.path; 
    config = {
      LISTEN_ADDR = "localhost:3001";
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  system.stateVersion = "25.11";
}
