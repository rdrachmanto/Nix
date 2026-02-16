{ config, pkgs, inputs, ... }:
{
  imports = [
    ../../base.nix
    # ./hardware-configuration.nix
  ];

  # Set timezone
  time.timeZone = "America/New_York";

  # Set device hostname
  networking.hostName = "rd-alexandria";

  environment.systemPackages = with pkgs; [];

  # Enable ssh into machine
  services.openssh.enable = true;

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
      "public" = {
        "path" = "/srv/Shares/Public";
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "main";
        "force group" = "users";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  networking.firewall.allowedTCPPorts = [];
  networking.firewall.trustedInterfaces = [ "tailscale0" ];

  system.stateVersion = "25.11";
}
