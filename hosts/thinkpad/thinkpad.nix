{ config, pkgs, inputs, ... }:
{
  nix.settings.extra-trusted-substituters = "https://cache.nixos-cuda.org";
  nix.settings.extra-trusted-public-keys = "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M=";

  imports = [
    ../../base.nix
    ./hardware-configuration.nix
  ];

  # Set timezone
  time.timeZone = "America/New_York";

  # Set device hostname
  networking.hostName = "rd-thinkpad";

  environment.systemPackages = with pkgs; [
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
    busybox
    dig

    # WM-specific settings
    # bar, notifications, OSD, launcher, etc.
    awww
    waybar
    swaylock
    swaynotificationcenter
    pwvucontrol
    vicinae

    # Desktop
    via                         # keyboard configurator
    firefox
    alacritty
    nautilus
    udiskie
    mpv
    zathura
    onlyoffice-desktopeditors
    swayimg

    # Virtualization
    distrobox

    # Trying out some packages/desktop apps!
    
    # Niceties
    htop
    fastfetch

    # Editors
    
    
    # academia
    drawio
    zotero

    (pkgs.texlive.combine {
      inherit (pkgs.texlive) scheme-medium
        wrapfig capt-of;
      # Add other packages here
    })
    
    texlive.combined.scheme-medium
    texlivePackages.wrapfig2

    # Programming languages
    gnumake
    gcc
    
    nil
    nixfmt

    vscode-langservers-extracted
    emmet-language-server

    micromamba
    python313
    python313Packages.virtualenv
    python313Packages.pip
    python313Packages.ruff
    basedpyright

    bash-language-server

    janet
    jpm

    # arduino-cli
    # R  # Don't forget to do `install.packages("languageserver")` in the R console
    
    # Dev Niceties
    
    # Niri-specific
    xwayland-satellite
  ];

  programs = {
    nix-ld.enable = true;
    
    niri.enable = true;
    xwayland.enable = true;

    # dms-shell = {
    #   enable = true;
    #   quickshell.package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.quickshell;
      
    #   systemd = {
    #     enable = true;
    #     restartIfChanged = true;
    #   };

    #   enableSystemMonitoring = true;
    #   # enableClipboard = true;
    #   enableVPN = true;
    #   enableAudioWavelength = true;
    #   enableCalendarEvents = true;
    #   enableDynamicTheming = true;
    # };

    nm-applet = {
      enable = true;
      indicator = true;
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
    # xserver.enable = true;
    xserver.videoDrivers = [
      "modesetting"
      "nvidia"
    ];
    displayManager.gdm.enable = false;
    flatpak.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    upower = {
      enable = true;
    };
    openssh.enable = true;
    fwupd.enable = true;
    emacs = {
      enable = true;
      defaultEditor = true;
      startWithGraphical = true;
      package = pkgs.emacs-pgtk;
    };

    blueman = {
      enable = true;
    };
    
  };

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
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
        # sync.enable = true;

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
}
