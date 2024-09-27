# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, inputs, lib, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nixos";
  # networking.wireless.enable = true;
  
  # Enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Remove local documentation
  documentation.nixos.enable = false;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Bucharest";

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

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.excludePackages = [ pkgs.xterm ];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  services.xserver.displayManager.gdm.wayland = true;

  # Remove gnome default applications
  services.gnome.core-utilities.enable = false;
  environment.gnome.excludePackages = [ pkgs.gnome-tour ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  systemd.services.suspend = {
    enable = true;
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "/bin/sh -c \"echo XHC0 > /proc/acpi/wakeup\"";
    };
    wantedBy = [ "multi-user.target" ];
  };

  virtualisation.docker = {
    enable = true;
    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  # Enable flatpak
  services.flatpak.enable = true;
  services.flatpak.remotes = [
    {
      name = "flathub"; location = "https://flathub.org/repo/flathub.flatpakrepo";
    }
    {
      name = "flathub-beta"; location = "https://flathub.org/beta-repo/flathub-beta.flatpakrepo";
    }
  ];
  services.flatpak.packages = [
    "ca.desrt.dconf-editor"
    "com.anydesk.Anydesk"
    "com.axosoft.GitKraken"
    "com.brave.Browser"
    "com.discordapp.Discord"
    "com.getpostman.Postman"
    "com.github.ADBeveridge.Raider"
    "com.github.PintaProject.Pinta"
    "com.github.finefindus.eyedropper"
    "com.github.tchx84.Flatseal"
    "com.mattjakeman.ExtensionManager"
    "com.mojang.Minecraft"
    "com.mongodb.Compass"
    "com.spotify.Client"
    "com.stremio.Stremio"
    "com.ultimaker.cura"
    "com.uploadedlobster.peek"
    "de.haeckerfelix.Fragments"
    "io.github.f3d_app.f3d"
    "io.github.seadve.Mousai"
    "io.github.spacingbat3.webcord"
    "io.github.zen_browser.zen"
    "it.mijorus.gearlever"
    "me.timschneeberger.jdsp4linux"
    "org.audacityteam.Audacity"
    "org.blender.Blender"
    "org.fedoraproject.MediaWriter"
    "org.gimp.GIMP"
    "org.gnome.Calculator"
    "org.gnome.Calendar"
    "org.gnome.Characters"
    "org.gnome.Evince"
    "org.gnome.FileRoller"
    "org.gnome.GHex"
    "org.gnome.Logs"
    "org.gnome.Loupe"
    "org.gnome.SimpleScan"
    "org.gnome.TextEditor"
    "org.gnome.Weather"
    "org.gnome.baobab"
    "org.gnome.clocks"
    "org.gnome.font-viewer"
    "org.libreoffice.LibreOffice"
  ];

  # Define a user account.
  users.users.gergoszaszvaradi = {
    isNormalUser = true;
    description = "gergoszaszvaradi";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Enable ZSH
  programs.zsh.enable = true;

  # Add steam
  programs.steam.enable = true;

  # Add virt-manager
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  programs.nautilus-open-any-terminal = {
    enable = true;
    terminal = "blackbox";
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget
    git
    fzf
    ripgrep
    lm_sensors
    xwaylandvideobridge
    solaar
    nautilus
    gnome-system-monitor
    blackbox-terminal
    emacs-gtk
    stow
    vscodium
    unrar
    wine
    winetricks
    bottles
    multiviewer-for-f1

    # GNOME extensions
    gnomeExtensions.appindicator
    gnomeExtensions.clipboard-indicator
    gnomeExtensions.custom-hot-corners-extended
    gnomeExtensions.dash-to-panel
    gnomeExtensions.emoji-copy
    gnomeExtensions.random-wallpaper
    gnomeExtensions.vitals

    # Development
    gnumake
    libgcc
    clang-tools
    cmake
    go
    python3
    nodePackages.nodejs

    # Other
    nerdfonts
  ];

  # Garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Enable auto-upgrade
  system.autoUpgrade = {
    enable = true;
    flake = inputs.self.outPath;
    flags = [
      "--update-input"
      "nixpkgs"
      "-L" # print build logs
    ];
    dates = "18:00";
    randomizedDelaySec = "45min";
  };

  # dconf settings
  programs.dconf = {
    enable = true;
    profiles.user.databases = [
      {
        lockAll = false;
        settings = {
          "org/gnome/shell" = {
            app-picker-layout = "'[]'";
            favorite-apps = "['com.brave.Browser.desktop', 'com.raggesilver.BlackBox.desktop', 'org.gnome.Nautilus.desktop']";
          };
          "org/gnome/desktop/wm/preferences" = {
            button-layout = "'appmenu:minimize,maximize,close'";
          };
          "org/gnome/desktop/interface" = {
            clock-show-date = true;
            clock-show-seconds = true;
            clock-show-weekday = true;
            color-scheme = "'prefer-dark'";
            enable-hot-corners = false;
          };
          "org/gnome/desktop/app-folders" = {
            folder-children = "'[]'";
          };
          "org/gnome/desktop/peripherals/keyboard" = {
            numlock-state = true;
            remember-numlock-state = true;
          };
          "org/gnome/mutter" = {
            edge-tiling = true;
          };
          "org/gnome/nautilus/preferences" = {
            default-folder-viewer = "'icon-view'";
            migrated-gtk-settings = true;
            search-filter-time-type = "'last_modified'";
          };
          "com/raggesilver/BlackBox" = {
            fill-tabs = true;
            font = "'CaskaydiaCove Nerd Font 11'";
            headerbar-drag-area = true;
            remember-window-size = true;
            terminal-padding = "(uint32 5, uint32 5, uint32 5, uint32 5)";
            theme-dark = "'Japanesque'";
            window-height = "uint32 753";
            window-width = "uint32 1320";
          };
          "com/github/stunkymonkey/nautilus-open-any-terminal" = {
            terminal = "'blackbox'";
          };
          "org/gnome/shell/extensions/appindicator" = {
            legacy-tray-enabled = false;
          };
          "org/gnome/shell/extensions/custom-hot-corners-extended/misc" = {
            panel-menu-enable = false;
          };
          "org/gnome/shell/extensions/custom-hot-corners-extended/monitor-0-bottom-left-0" = {
            action = "'toggle-overview'";
            barrier-size-h = "i 98";
          };
          "org/gnome/shell/extensions/custom-hot-corners-extended/monitor-1-bottom-left-0" = {
            action = "'toggle-overview'";
            barrier-size-h = "i 98";
          };
          "org/gnome/shell/extensions/dash-to-panel" = {
            panel-element-positions-monitors-sync = true;
            panel-anchors = "'{\"0\":\"MIDDLE\",\"1\":\"MIDDLE\"}'";
            panel-element-positions="'{\"0\":[{\"element\":\"showAppsButton\",\"visible\":false,\"position\":\"stackedTL\"},{\"element\":\"activitiesButton\",\"visible\":true,\"position\":\"stackedTL\"},{\"element\":\"leftBox\",\"visible\":true,\"position\":\"stackedTL\"},{\"element\":\"taskbar\",\"visible\":false,\"position\":\"stackedTL\"},{\"element\":\"centerBox\",\"visible\":false,\"position\":\"stackedBR\"},{\"element\":\"dateMenu\",\"visible\":true,\"position\":\"centerMonitor\"},{\"element\":\"rightBox\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"systemMenu\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"desktopButton\",\"visible\":false,\"position\":\"stackedBR\"}],\"1\":[{\"element\":\"showAppsButton\",\"visible\":false,\"position\":\"stackedTL\"},{\"element\":\"activitiesButton\",\"visible\":true,\"position\":\"stackedTL\"},{\"element\":\"leftBox\",\"visible\":true,\"position\":\"stackedTL\"},{\"element\":\"taskbar\",\"visible\":false,\"position\":\"stackedTL\"},{\"element\":\"centerBox\",\"visible\":false,\"position\":\"stackedBR\"},{\"element\":\"dateMenu\",\"visible\":true,\"position\":\"centerMonitor\"},{\"element\":\"rightBox\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"systemMenu\",\"visible\":true,\"position\":\"stackedBR\"},{\"element\":\"desktopButton\",\"visible\":false,\"position\":\"stackedBR\"}]}'";
            panel-positions="'{\"0\":\"TOP\",\"1\":\"TOP\"}'";
            panel-sizes = "'{\"0\":32,\"1\":32}'";
          };
          "org/gnome/shell/extensions/space-iflow-randomwallpaper" = {
            auto-fetch = false;
            change-type = "i 2";
            sources = "['1726986491471']";
            fetch-on-startup = true;
            hide-panel-icon = true;
          };
          "org/gnome/shell/extensions/space-iflow-randomwallpaper/sources/general/1726986491471" = {
            name = "'Wallpapers'";
            type = "i 4";
          };
          "org/gnome/shell/extensions/space-iflow-randomwallpaper/sources/localFolder/1726986491471" = {
            folder = "'/home/gergoszaszvaradi/Pictures/Wallpapers'";
          };
          "org/gnome/shell/extensions/vitals" = {
            hot-sensors="['_processor_usage_', '_memory_usage_', '__temperature_avg__', '_gpu#1_utilization_', '_gpu#1_memory_utilization_', '_gpu#1_temperature_']";
            show-fan = false;
            show-gpu = true;
            show-network = false;
            show-voltage = false;
          };
        };
      }
    ];
  };

  # Xbox Controller
  hardware.xone.enable = true;

  # NVIDIA
  hardware.graphics.enable = true;

  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = false;
    powerManagement.finegrained = false;
    open = false;
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?

}
