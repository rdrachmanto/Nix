# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, self, ... }:

let
  system = "x86_64-linux";
  janetLsp = self.packages.${system}."janet-lsp";
in {
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
  networking.networkmanager = {
    enable = true;
    plugins = with pkgs; [
      networkmanager-fortisslvpn
      networkmanager-iodine
      networkmanager-l2tp
      networkmanager-openconnect
      networkmanager-openvpn
      networkmanager-vpnc
      networkmanager-sstp
    ];
  };

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
      "dialout"
    ];
    shell = pkgs.zsh;
    packages = [ ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.input-fonts.acceptLicense = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.localBinInPath = true;
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
    gzip

    # Desktop
    firefox
    alacritty
    swww
    rofi

    # File manager
    nautilus
    udiskie
    
    mpv
    zathura
    onlyoffice-desktopeditors
    swayimg

    # Trying out some packages/desktop apps!
    cmatrix
    
    # Niceties
    bat
    btop
    fastfetch

    # Editors
    emacs-pgtk
    zed-editor

    # academia
    zotero
    typst
    tinymist
    texlive.combined.scheme-medium

    # Programming languages
    gnumake
    gcc
    
    nil
    nixfmt

    vscode-langservers-extracted
    emmet-language-server

    python313
    python313Packages.virtualenv
    python313Packages.pip
    python313Packages.ruff
    basedpyright

    bash-language-server

    arduino-cli
    R  # Don't forget to do `install.packages("languageserver")` in the R console
    
    # Dev Niceties
    zeal
    
    # Niri-specific
    xwayland-satellite
  ];

  programs = {
    nix-ld.enable = true;
    
    niri.enable = true;
    xwayland.enable = true;

    dms-shell = {
      enable = true;
      quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
      
      systemd = {
        enable = true;
        restartIfChanged = true;
      };

      enableSystemMonitoring = true;
      enableClipboard = true;
      enableVPN = true;
      enableAudioWavelength = true;
      enableCalendarEvents = true;
      enableDynamicTheming = true;
    };

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

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    java = {
      enable = true;
      package = pkgs.jdk17;
    };

    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
      extraCompatPackages = with pkgs; [ proton-ge-bin ];
      extraPackages = with pkgs; [ gamescope ];
    };
  };

  fonts = {
    fontconfig.enable = true;
    packages = with pkgs; [
      nerd-fonts.zed-mono
      input-fonts
      maple-mono.NF
      nerd-fonts.iosevka
    ];
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gnome
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
    gvfs.enable = true;
  };

  hardware = {
    graphics.enable = true;
    bluetooth.enable = true;
    nvidia = {
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
  };

  # Power management
  powerManagement.enable = true;

  environment.variables = {
    GSK_RENDER = "ngl";
    GSK_RENDERER = "ngl";
  };
  
  environment.etc."xdg-desktop-portal/niri-portals.conf".text = ''
    [preferred]
    org.freedesktop.impl.portal.FileChooser=gnome;
    org.freedesktop.impl.portal.Access=gnome;
    org.freedesktop.impl.portal.Notification=gnome;
    org.freedesktop.impl.portal.Secret=gnome-keyring;
  '';  

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

  networking.extraHosts = ''
    172.20.148.125 rd-srv-atlas.lab
  '';

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?
}
