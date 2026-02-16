let
  batavia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDfNAB5msmswUFTj0qRjF8zSBOkTmdhVSnvf45rVX0r5 root@nixos";
in {
  "caddy.age".publicKeys = [batavia];
}
