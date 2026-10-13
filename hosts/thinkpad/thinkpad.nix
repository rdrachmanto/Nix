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
    cliphist
    polkit

    # WM-specific settings
    # bar, notifications, OSD, launcher, etc.
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    vicinae
    brightnessctl

    # Desktop
    firefox
    alacritty

    adwaita-icon-theme
    nautilus
    udiskie
    
    celluloid
    zathura
    onlyoffice-desktopeditors
    swayimg

    powertop
    nvtopPackages.nvidia

    # Virtualization
    distrobox
    rpi-imager

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
    vscode-fhs
    
    # Niri-specific
    xwayland-satellite
  ];

  programs = {
    nix-ld.enable = true;
    nix-ld.libraries = with pkgs; [
      stdenv.cc.cc.lib   # libstdc++
      zlib
      glib
      libGL
      libX11
    ];

    niri.enable = true;
    xwayland.enable = true;

    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
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
    flatpak.enable = true;
    udisks2.enable = true;
    gvfs.enable = true;
    upower = {
      enable = true;
    };
    fwupd.enable = true;
    emacs = {
      enable = true;
      defaultEditor = true;
      startWithGraphical = true;
      package = pkgs.emacs-pgtk;
    };

    auto-cpufreq = {
      enable = true;
      settings.battery = {
        governor = "powersave";
        turbo = "never";
      };
      settings.charger = {
        governor = "performance";
        turbo = "auto";
      };
    };

    syncthing = {
      enable = true;
      user = "rd";
      dataDir = "/home/rd";

      overrideDevices = true;
      overrideFolders = true;
      guiAddress = "127.0.0.1:8384";
      openDefaultPorts = true;
      
      settings = {
        devices = {
          "rd-batavia" = {
            id = "MGJE545-NVYE7C7-L6QWLCQ-DERIKOF-LS3XWYC-YFE4JX2-LAAX5WO-MNNJ2AR";
            addresses = [ "tcp://100.118.182.21" ];
          };
        };
        folders = {
          "Documents" = {
            path = "/home/rd/Documents";
            devices = [ "rd-batavia" ];
            ignorePerms = false;
          };
          "Research" = {
            path = "/home/rd/Research";
            devices = [ "rd-batavia" ];
            ignorePerms = false;
          };
        };
      };
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
