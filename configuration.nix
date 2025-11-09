# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "rd-thinkpad"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/New_York";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.rdrachmanto = {
    isNormalUser = true;
    description = "Rakandhiya Daanii Rachmanto";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    shell = pkgs.zsh;
    packages = with pkgs; [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    #  wget
    wget
    curl
    git
    tmux
    fzf
    fd
    ripgrep
    cliphist
    nmap
    polkit
    stow
    lshw
    unzip

    # Desktop
    firefox
    alacritty
    swww
    swaylock
    waybar
    mako
    fuzzel
    rofi
    networkmanager
    networkmanagerapplet
    blueman
    pulsemixer
    nautilus
    udiskie
    mpv
    zathura

    # Niceties
    bat
    btop
    fastfetch

    # Editors
    emacs

    # Programming languages
    rustup
    nil
    nixfmt

    # Niri-specific
    xwayland-satellite
  ];

  programs = {
    nix-ld.enable = true;
    
    niri.enable = true;
    xwayland.enable = true;
    
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
    };

    starship = {
      enable = true;
      interactiveOnly = true;
    };
    zsh = {
      enable = true;
      autosuggestions.enable = true;
      enableCompletion = true;
      enableLsColors = true;
    };
    
    git = {
      enable = true;
      config = {
        init = {
          defaultBranch = "main";
        };
      };
    };
  };

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.zed-mono
      nerd-fonts.iosevka-term
      nerd-fonts.jetbrains-mono
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  services = {
    xserver.enable = true;
    xserver.videoDrivers = [
      "modesetting"
      "nvidia"
    ];
    xserver.displayManager.gdm.enable = true;
    flatpak.enable = true;
    udisks2.enable = true;
  };

  hardware = {
    graphics.enable = true;
    bluetooth.enable = true;
  };

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = true;
    nvidiaSettings = true;

    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  security.polkit.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
