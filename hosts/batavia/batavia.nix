{ config, pkgs, inputs, ... }:
{
  imports = [
    ../../base.nix
    # ./hardware-configuration.nix
  ];

  # Set timezone
  time.timeZone = "America/New_York";

  # Set device hostname
  networking.hostName = "rd-batavia";

  environment.systemPackages = with pkgs; [];

  # Enable ssh into machine
  services.openssh.enable = true;

  services.caddy = {
    enable = true;
    package = pkgs.caddy.withPlugins {
      plugins = [ "github.com/caddy-dns/porkbun@v0.3.1" ];
      hash = "sha256-R1ZqQ8drcBQIH7cLq9kEvdg9Ze3bKkT8IAFavldVeC0=";
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
    virtualHosts."glances.lab.rdrachmanto.dev".extraConfig = ''
      reverse_proxy http://127.0.0.1:61208
    '';
    virtualHosts."rss.lab.rdrachmanto.dev".extraConfig = ''
      reverse_proxy http://127.0.0.1:7070
    '';
  };
  systemd.services.caddy.serviceConfig.EnvironmentFile = ["/etc/caddy/envfile"];

  services.dnsmasq = {
    enable = true;
    settings = {
      interface = "tailscale0";
      bind-dynamic = true;

      local = "/lab.rdrachmanto.dev/";
      address = "/lab.rdrachmanto.dev/100.125.252.49";

      domain-needed = true;
      bogus-priv = true;
    };
  };

  services.glances.enable = true;
  services.yarr.enable = true;

  networking.firewall.allowedTCPPorts = [];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  system.stateVersion = "25.11";
}
