let
  rd-batavia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIMFZElz6ty3XrdBU8zCTaF+wDWG+GCP1nesxk1u7Y/F rd@rd-batavia";
  root-batavia = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIB+pq0WdRG2FNQQt33t0nTUmE+3NBDBjFV43nF2BHEki root@nixos";
in {
  "caddy.age".publicKeys = [rd-batavia root-batavia];
}
