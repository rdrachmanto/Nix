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
  
  users.users.rd = {
    extraGroups = [ "git" "podman" ];
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
      reverse_proxy http://127.0.0.1:3333
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
      address = "/lab.rdrachmanto.dev/100.118.182.21";

      domain-needed = true;
      bogus-priv = true;
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

  networking.firewall.allowedTCPPorts = [ 80 443 4533 9000 ];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  system.stateVersion = "25.11";
}
