{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  makeIni = (pkgs.formats.ini { }).generate;
  imageMapRange =
    image: sourceColorStart: sourceColorEnd: destinationColorStart: destinationColorEnd:
    pkgs.stdenvNoCC.mkDerivation {
      name = "${image.name or builtins.baseNameOf image}.recolored.png";
      nativeBuildInputs = [ pkgs.imagemagick ];

      phases = [ "installPhase" ];
      installPhase = ''
        magick "${image}" \
          -level-colors "${sourceColorStart}":"${sourceColorEnd}" \
          -colorspace Gray \
          +level-colors "${destinationColorStart}":"${destinationColorEnd}" \
          PNG:$out
      '';
    };
  secsFromMins = minutes: 60 * minutes;

  user = "rasmus";
  theme = "breeze-clean";
  # Wallpapers by Sameera Sandakelum:
  # https://photos.app.goo.gl/vm9UudLFVqMrcyKW7
  loginBackground =
    imageMapRange ../../assets/zen-coral-white-dim.jpeg "#F66E51" "white" "#BC97FF"
      "white";
  desktopBackground = ../../assets/zen-dark-coral-dim.jpeg;
  sddmUserThemeConfig = makeIni "theme.conf.user" {
    General = {
      background = "${loginBackground}";
    };
  };
in
{
  imports = [ ];

  config = {
    # Enable the wayland windowing system. (does this sentence even make sense ._.)
    services.displayManager.sddm.wayland.enable = true;

    # Enable the KDE Plasma Desktop Environment.
    services.displayManager.sddm.enable = true;
    services.desktopManager.plasma6.enable = true;
    # So turns out that enabling this currently makes loging through SDDM take
    # much longer. This is a known problem that still hasn't been fixed:
    # https://github.com/sddm/sddm/issues/1840
    # https://github.com/sddm/sddm/pull/1220
    # Make some day I will revisit this and try to solve it.
    # # Enable fingerprint reader handling
    # services.fprintd.enable = true;

    # Make SDDM use the same config files as the specified user. This makes sure
    # that the current display settings used in my desktop is applied in SDDM.
    # (Maybe it's possible to make SDDM use my dark theme...)
    # TODO: This should probably be written as a systemd service.
    system.activationScripts.copySddmConfig = {
      deps = [
        "var"
        "users"
      ];
      text = ''
        mkdir -p /var/lib/sddm/.config

        any_changed=false
        copy_if_exists() {
          if [ -f /home/${user}/$1 ]; then
            cp /home/${user}/$1 /var/lib/sddm/$1
            any_changed=true
          fi
        }

        copy_if_exists .config/kwinoutputconfig.json
        copy_if_exists .config/kcminputrc

        if [ $any_changed = true ]; then
          echo "copied ${user}'s config into /var/lib/sddm/.config/"
        fi

        chown sddm:sddm /var/lib/sddm/.config/
      '';
    };

    environment.systemPackages = [
      (pkgs.atPath sddmUserThemeConfig "share/sddm/themes/${theme}/${sddmUserThemeConfig.name}")
      (pkgs.callPackage ./breeze-clean.nix { })
    ];

    services.displayManager.sddm.settings = {
      Theme = {
        Current = theme;
      };
    };
  };

  # Home manager configuration
  config.home-manager.users.${user} =
    {
      lib,
      config,
      pkgs,
      inputs,
      ...
    }:
    {
      imports = [
        inputs.plasma-manager.homeManagerModules.plasma-manager
      ];

      home.packages = [
        # Allows kde system settings UI to edit SDDM settings.
        pkgs.kdePackages.sddm-kcm
      ];

      programs.plasma = {
        enable = true;

        # Lockscreen wallpaper
        kscreenlocker.appearance.wallpaper = loginBackground;
        workspace.wallpaper = desktopBackground;

        # Power settings
        powerdevil = {
          AC = {
            displayBrightness = 100;
            # Never go to sleep/turn off
            autoSuspend.action = "nothing";
            dimDisplay.idleTimeout = secsFromMins 5;
            turnOffDisplay.idleTimeout = "never";
          };
        };

        shortcuts = {
          "ActivityManager"."switch-to-activity-dad1e87e-84fb-4f4e-aa0f-cb086bfb65a6" = [ ];
          "KDE Keyboard Layout Switcher"."Switch keyboard layout to Swedish" = [ ];
          "KDE Keyboard Layout Switcher"."Switch to Last-Used Keyboard Layout" = "Meta+Alt+L";
          "KDE Keyboard Layout Switcher"."Switch to Next Keyboard Layout" = "Meta+Alt+K";
          "kaccess"."Toggle Screen Reader On and Off" = "Meta+Alt+S";
          "kcm_touchpad"."Disable Touchpad" = "Touchpad Off";
          "kcm_touchpad"."Enable Touchpad" = "Touchpad On";
          "kcm_touchpad"."Toggle Touchpad" = [
            "Touchpad Toggle"
            "Meta+Ctrl+Zenkaku Hankaku,Touchpad Toggle"
            "Meta+Ctrl+Zenkaku Hankaku"
          ];
          "kmix"."decrease_microphone_volume" = "Microphone Volume Down";
          "kmix"."decrease_volume" = "Volume Down";
          "kmix"."decrease_volume_small" = "Shift+Volume Down";
          "kmix"."increase_microphone_volume" = "Microphone Volume Up";
          "kmix"."increase_volume" = "Volume Up";
          "kmix"."increase_volume_small" = "Shift+Volume Up";
          "kmix"."mic_mute" = [
            "Microphone Mute"
            "Meta+Volume Mute,Microphone Mute"
            "Meta+Volume Mute,Mute Microphone"
          ];
          "kmix"."mute" = "Volume Mute";
          "ksmserver"."Halt Without Confirmation" = "none,,Shut Down Without Confirmation";
          "ksmserver"."Lock Session" = [
            "Meta+L"
            "Screensaver,Meta+L"
            "Screensaver,Lock Session"
          ];
          "ksmserver"."Log Out" = "Ctrl+Alt+Del";
          "ksmserver"."Log Out Without Confirmation" = "none,,Log Out Without Confirmation";
          "ksmserver"."Reboot" = "none,,Reboot";
          "ksmserver"."Reboot Without Confirmation" = "none,,Reboot Without Confirmation";
          "ksmserver"."Shut Down" = "none,,Shut Down";
          "kwin"."Activate Window Demanding Attention" = "Meta+Ctrl+A";
          "kwin"."Cycle Overview" = [ ];
          "kwin"."Cycle Overview Opposite" = [ ];
          "kwin"."Decrease Opacity" = "none,,Decrease Opacity of Active Window by 5%";
          "kwin"."Edit Tiles" = "Meta+T";
          "kwin"."Expose" = "Ctrl+F9";
          "kwin"."ExposeAll" = [
            "Ctrl+F10"
            "Launch (C),Ctrl+F10"
            "Launch (C),Toggle Present Windows (All desktops)"
          ];
          "kwin"."ExposeClass" = "Ctrl+F7";
          "kwin"."ExposeClassCurrentDesktop" = [ ];
          "kwin"."Grid View" = "Meta+G";
          "kwin"."Increase Opacity" = "none,,Increase Opacity of Active Window by 5%";
          "kwin"."Kill Window" = "Meta+Ctrl+Esc";
          "kwin"."Move Tablet to Next Output" = [ ];
          "kwin"."MoveMouseToCenter" = "Meta+F6";
          "kwin"."MoveMouseToFocus" = "Meta+F5";
          "kwin"."MoveZoomDown" = [ ];
          "kwin"."MoveZoomLeft" = [ ];
          "kwin"."MoveZoomRight" = [ ];
          "kwin"."MoveZoomUp" = [ ];
          "kwin"."Overview" = "Meta+W";
          "kwin"."Setup Window Shortcut" = "none,,Setup Window Shortcut";
          "kwin"."Show Desktop" = "Meta+D";
          "kwin"."Switch One Desktop Down" = "Meta+Ctrl+Down";
          "kwin"."Switch One Desktop Up" = "Meta+Ctrl+Up";
          "kwin"."Switch One Desktop to the Left" = "Meta+Ctrl+Left";
          "kwin"."Switch One Desktop to the Right" = "Meta+Ctrl+Right";
          "kwin"."Switch Window Down" = "Meta+Alt+Down";
          "kwin"."Switch Window Left" = "Meta+Alt+Left";
          "kwin"."Switch Window Right" = "Meta+Alt+Right";
          "kwin"."Switch Window Up" = "Meta+Alt+Up";
          "kwin"."Switch to Desktop 1" = "Ctrl+F1";
          "kwin"."Switch to Desktop 10" = "none,,Switch to Desktop 10";
          "kwin"."Switch to Desktop 11" = "none,,Switch to Desktop 11";
          "kwin"."Switch to Desktop 12" = "none,,Switch to Desktop 12";
          "kwin"."Switch to Desktop 13" = "none,,Switch to Desktop 13";
          "kwin"."Switch to Desktop 14" = "none,,Switch to Desktop 14";
          "kwin"."Switch to Desktop 15" = "none,,Switch to Desktop 15";
          "kwin"."Switch to Desktop 16" = "none,,Switch to Desktop 16";
          "kwin"."Switch to Desktop 17" = "none,,Switch to Desktop 17";
          "kwin"."Switch to Desktop 18" = "none,,Switch to Desktop 18";
          "kwin"."Switch to Desktop 19" = "none,,Switch to Desktop 19";
          "kwin"."Switch to Desktop 2" = "Ctrl+F2";
          "kwin"."Switch to Desktop 20" = "none,,Switch to Desktop 20";
          "kwin"."Switch to Desktop 3" = "Ctrl+F3";
          "kwin"."Switch to Desktop 4" = "Ctrl+F4";
          "kwin"."Switch to Desktop 5" = "none,,Switch to Desktop 5";
          "kwin"."Switch to Desktop 6" = "none,,Switch to Desktop 6";
          "kwin"."Switch to Desktop 7" = "none,,Switch to Desktop 7";
          "kwin"."Switch to Desktop 8" = "none,,Switch to Desktop 8";
          "kwin"."Switch to Desktop 9" = "none,,Switch to Desktop 9";
          "kwin"."Switch to Next Desktop" = "none,,Switch to Next Desktop";
          "kwin"."Switch to Next Screen" = "none,,Switch to Next Screen";
          "kwin"."Switch to Previous Desktop" = "none,,Switch to Previous Desktop";
          "kwin"."Switch to Previous Screen" = "none,,Switch to Previous Screen";
          "kwin"."Switch to Screen 0" = "none,,Switch to Screen 0";
          "kwin"."Switch to Screen 1" = "none,,Switch to Screen 1";
          "kwin"."Switch to Screen 2" = "none,,Switch to Screen 2";
          "kwin"."Switch to Screen 3" = "none,,Switch to Screen 3";
          "kwin"."Switch to Screen 4" = "none,,Switch to Screen 4";
          "kwin"."Switch to Screen 5" = "none,,Switch to Screen 5";
          "kwin"."Switch to Screen 6" = "none,,Switch to Screen 6";
          "kwin"."Switch to Screen 7" = "none,,Switch to Screen 7";
          "kwin"."Switch to Screen Above" = "none,,Switch to Screen Above";
          "kwin"."Switch to Screen Below" = "none,,Switch to Screen Below";
          "kwin"."Switch to Screen to the Left" = "none,,Switch to Screen to the Left";
          "kwin"."Switch to Screen to the Right" = "none,,Switch to Screen to the Right";
          "kwin"."Toggle Night Color" = [ ];
          "kwin"."Toggle Window Raise/Lower" = "none,,Toggle Window Raise/Lower";
          "kwin"."Walk Through Windows" = "Alt+Tab";
          "kwin"."Walk Through Windows (Reverse)" = "Alt+Shift+Tab";
          "kwin"."Walk Through Windows Alternative" = "none,,Walk Through Windows Alternative";
          "kwin"."Walk Through Windows Alternative (Reverse)" =
            "none,,Walk Through Windows Alternative (Reverse)";
          "kwin"."Walk Through Windows of Current Application" = "Alt+`";
          "kwin"."Walk Through Windows of Current Application (Reverse)" = "Alt+~";
          "kwin"."Walk Through Windows of Current Application Alternative" =
            "none,,Walk Through Windows of Current Application Alternative";
          "kwin"."Walk Through Windows of Current Application Alternative (Reverse)" =
            "none,,Walk Through Windows of Current Application Alternative (Reverse)";
          "kwin"."Window Above Other Windows" = "none,,Keep Window Above Others";
          "kwin"."Window Below Other Windows" = "none,,Keep Window Below Others";
          "kwin"."Window Close" = "Alt+F4";
          "kwin"."Window Fullscreen" = "none,,Make Window Fullscreen";
          "kwin"."Window Grow Horizontal" = "none,,Expand Window Horizontally";
          "kwin"."Window Grow Vertical" = "none,,Expand Window Vertically";
          "kwin"."Window Lower" = "none,,Lower Window";
          "kwin"."Window Maximize" = "Meta+PgUp";
          "kwin"."Window Maximize Horizontal" = "none,,Maximize Window Horizontally";
          "kwin"."Window Maximize Vertical" = "none,,Maximize Window Vertically";
          "kwin"."Window Minimize" = "Meta+PgDown";
          "kwin"."Window Move" = "none,,Move Window";
          "kwin"."Window Move Center" = "none,,Move Window to the Center";
          "kwin"."Window No Border" = "none,,Toggle Window Titlebar and Frame";
          "kwin"."Window On All Desktops" = "none,,Keep Window on All Desktops";
          "kwin"."Window One Desktop Down" = "Meta+Ctrl+Shift+Down";
          "kwin"."Window One Desktop Up" = "Meta+Ctrl+Shift+Up";
          "kwin"."Window One Desktop to the Left" = "Meta+Ctrl+Shift+Left";
          "kwin"."Window One Desktop to the Right" = "Meta+Ctrl+Shift+Right";
          "kwin"."Window One Screen Down" = "none,,Move Window One Screen Down";
          "kwin"."Window One Screen Up" = "none,,Move Window One Screen Up";
          "kwin"."Window One Screen to the Left" = "none,,Move Window One Screen to the Left";
          "kwin"."Window One Screen to the Right" = "none,,Move Window One Screen to the Right";
          "kwin"."Window Operations Menu" = "Alt+F3";
          "kwin"."Window Pack Down" = "none,,Move Window Down";
          "kwin"."Window Pack Left" = "none,,Move Window Left";
          "kwin"."Window Pack Right" = "none,,Move Window Right";
          "kwin"."Window Pack Up" = "none,,Move Window Up";
          "kwin"."Window Quick Tile Bottom" = "Meta+Down";
          "kwin"."Window Quick Tile Bottom Left" = "none,,Quick Tile Window to the Bottom Left";
          "kwin"."Window Quick Tile Bottom Right" = "none,,Quick Tile Window to the Bottom Right";
          "kwin"."Window Quick Tile Left" = "Meta+Left";
          "kwin"."Window Quick Tile Right" = "Meta+Right";
          "kwin"."Window Quick Tile Top" = "Meta+Up";
          "kwin"."Window Quick Tile Top Left" = "none,,Quick Tile Window to the Top Left";
          "kwin"."Window Quick Tile Top Right" = "none,,Quick Tile Window to the Top Right";
          "kwin"."Window Raise" = "none,,Raise Window";
          "kwin"."Window Resize" = "none,,Resize Window";
          "kwin"."Window Shade" = "none,,Shade Window";
          "kwin"."Window Shrink Horizontal" = "none,,Shrink Window Horizontally";
          "kwin"."Window Shrink Vertical" = "none,,Shrink Window Vertically";
          "kwin"."Window to Desktop 1" = "none,,Window to Desktop 1";
          "kwin"."Window to Desktop 10" = "none,,Window to Desktop 10";
          "kwin"."Window to Desktop 11" = "none,,Window to Desktop 11";
          "kwin"."Window to Desktop 12" = "none,,Window to Desktop 12";
          "kwin"."Window to Desktop 13" = "none,,Window to Desktop 13";
          "kwin"."Window to Desktop 14" = "none,,Window to Desktop 14";
          "kwin"."Window to Desktop 15" = "none,,Window to Desktop 15";
          "kwin"."Window to Desktop 16" = "none,,Window to Desktop 16";
          "kwin"."Window to Desktop 17" = "none,,Window to Desktop 17";
          "kwin"."Window to Desktop 18" = "none,,Window to Desktop 18";
          "kwin"."Window to Desktop 19" = "none,,Window to Desktop 19";
          "kwin"."Window to Desktop 2" = "none,,Window to Desktop 2";
          "kwin"."Window to Desktop 20" = "none,,Window to Desktop 20";
          "kwin"."Window to Desktop 3" = "none,,Window to Desktop 3";
          "kwin"."Window to Desktop 4" = "none,,Window to Desktop 4";
          "kwin"."Window to Desktop 5" = "none,,Window to Desktop 5";
          "kwin"."Window to Desktop 6" = "none,,Window to Desktop 6";
          "kwin"."Window to Desktop 7" = "none,,Window to Desktop 7";
          "kwin"."Window to Desktop 8" = "none,,Window to Desktop 8";
          "kwin"."Window to Desktop 9" = "none,,Window to Desktop 9";
          "kwin"."Window to Next Desktop" = "none,,Window to Next Desktop";
          "kwin"."Window to Next Screen" = "Meta+Shift+Right";
          "kwin"."Window to Previous Desktop" = "none,,Window to Previous Desktop";
          "kwin"."Window to Previous Screen" = "Meta+Shift+Left";
          "kwin"."Window to Screen 0" = "none,,Move Window to Screen 0";
          "kwin"."Window to Screen 1" = "none,,Move Window to Screen 1";
          "kwin"."Window to Screen 2" = "none,,Move Window to Screen 2";
          "kwin"."Window to Screen 3" = "none,,Move Window to Screen 3";
          "kwin"."Window to Screen 4" = "none,,Move Window to Screen 4";
          "kwin"."Window to Screen 5" = "none,,Move Window to Screen 5";
          "kwin"."Window to Screen 6" = "none,,Move Window to Screen 6";
          "kwin"."Window to Screen 7" = "none,,Move Window to Screen 7";
          "kwin"."view_actual_size" = "Meta+0";
          "kwin"."view_zoom_in" = [
            "Meta++"
            "Meta+=,Meta++"
            "Meta+=,Zoom In"
          ];
          "kwin"."view_zoom_out" = "Meta+-";
          "mediacontrol"."mediavolumedown" = "none,,Media volume down";
          "mediacontrol"."mediavolumeup" = "none,,Media volume up";
          "mediacontrol"."nextmedia" = "Media Next";
          "mediacontrol"."pausemedia" = "Media Pause";
          "mediacontrol"."playmedia" = "none,,Play media playback";
          "mediacontrol"."playpausemedia" = "Media Play";
          "mediacontrol"."previousmedia" = "Media Previous";
          "mediacontrol"."stopmedia" = "Media Stop";
          "org_kde_powerdevil"."Decrease Keyboard Brightness" = "Keyboard Brightness Down";
          "org_kde_powerdevil"."Decrease Screen Brightness" = "Monitor Brightness Down";
          "org_kde_powerdevil"."Decrease Screen Brightness Small" = "Shift+Monitor Brightness Down";
          "org_kde_powerdevil"."Hibernate" = "Hibernate";
          "org_kde_powerdevil"."Increase Keyboard Brightness" = "Keyboard Brightness Up";
          "org_kde_powerdevil"."Increase Screen Brightness" = "Monitor Brightness Up";
          "org_kde_powerdevil"."Increase Screen Brightness Small" = "Shift+Monitor Brightness Up";
          "org_kde_powerdevil"."PowerDown" = "Power Down";
          "org_kde_powerdevil"."PowerOff" = "Power Off";
          "org_kde_powerdevil"."Sleep" = "Sleep";
          "org_kde_powerdevil"."Toggle Keyboard Backlight" = "Keyboard Light On/Off";
          "org_kde_powerdevil"."Turn Off Screen" = [ ];
          "org_kde_powerdevil"."powerProfile" = [
            "Battery"
            "Meta+B,Battery"
            "Meta+B,Switch Power Profile"
          ];
          "plasmashell"."activate task manager entry 1" = "Meta+1";
          "plasmashell"."activate task manager entry 10" = "none,Meta+0,Activate Task Manager Entry 10";
          "plasmashell"."activate task manager entry 2" = "Meta+2";
          "plasmashell"."activate task manager entry 3" = "Meta+3";
          "plasmashell"."activate task manager entry 4" = "Meta+4";
          "plasmashell"."activate task manager entry 5" = "Meta+5";
          "plasmashell"."activate task manager entry 6" = "Meta+6";
          "plasmashell"."activate task manager entry 7" = "Meta+7";
          "plasmashell"."activate task manager entry 8" = "Meta+8";
          "plasmashell"."activate task manager entry 9" = "Meta+9";
          "plasmashell"."clear-history" = "none,,Clear Clipboard History";
          "plasmashell"."clipboard_action" = "Meta+Ctrl+X";
          "plasmashell"."cycle-panels" = "Meta+Alt+P";
          "plasmashell"."cycleNextAction" = "none,,Next History Item";
          "plasmashell"."cyclePrevAction" = "none,,Previous History Item";
          "plasmashell"."manage activities" = "Meta+Q";
          "plasmashell"."next activity" = "Meta+A,none,Walk through activities";
          "plasmashell"."previous activity" = "Meta+Shift+A,none,Walk through activities (Reverse)";
          "plasmashell"."repeat_action" = "none,Meta+Ctrl+R,Manually Invoke Action on Current Clipboard";
          "plasmashell"."show dashboard" = "Ctrl+F12";
          "plasmashell"."show-barcode" = "none,,Show Barcode…";
          "plasmashell"."show-on-mouse-pos" = "Meta+V";
          "plasmashell"."stop current activity" = "Meta+S";
          "plasmashell"."switch to next activity" = "none,,Switch to Next Activity";
          "plasmashell"."switch to previous activity" = "none,,Switch to Previous Activity";
          "plasmashell"."toggle do not disturb" = "none,,Toggle do not disturb";
        };
        configFile = {
          "baloofilerc" = {
            "General"."dbVersion" = 2;
            "General"."exclude filters" =
              "*~,*.part,*.o,*.la,*.lo,*.loT,*.moc,moc_*.cpp,qrc_*.cpp,ui_*.h,cmake_install.cmake,CMakeCache.txt,CTestTestfile.cmake,libtool,config.status,confdefs.h,autom4te,conftest,confstat,Makefile.am,*.gcode,.ninja_deps,.ninja_log,build.ninja,*.csproj,*.m4,*.rej,*.gmo,*.pc,*.omf,*.aux,*.tmp,*.po,*.vm*,*.nvram,*.rcore,*.swp,*.swap,lzo,litmain.sh,*.orig,.histfile.*,.xsession-errors*,*.map,*.so,*.a,*.db,*.qrc,*.ini,*.init,*.img,*.vdi,*.vbox*,vbox.log,*.qcow2,*.vmdk,*.vhd,*.vhdx,*.sql,*.sql.gz,*.ytdl,*.tfstate*,*.class,*.pyc,*.pyo,*.elc,*.qmlc,*.jsc,*.fastq,*.fq,*.gb,*.fasta,*.fna,*.gbff,*.faa,po,CVS,.svn,.git,_darcs,.bzr,.hg,CMakeFiles,CMakeTmp,CMakeTmpQmake,.moc,.obj,.pch,.uic,.npm,.yarn,.yarn-cache,__pycache__,node_modules,node_packages,nbproject,.terraform,.venv,venv,core-dumps,lost+found";
            "General"."exclude filters version" = 9;
          };
          "dolphinrc" = {
            "ContentDisplay"."UseShortRelativeDates" = false;
            "General"."OpenExternallyCalledFolderInNewTab" = true;
            "General"."OpenNewTabAfterLastTab" = true;
            "General"."ShowFullPathInTitlebar" = true;
            "General"."ViewPropsTimestamp" = "2024,8,24,13,15,27.405";
            "KFileDialog Settings"."Places Icons Auto-resize" = false;
            "KFileDialog Settings"."Places Icons Static Size" = 22;
            "PreviewSettings"."Plugins" =
              "appimagethumbnail,audiothumbnail,blenderthumbnail,comicbookthumbnail,cursorthumbnail,djvuthumbnail,ebookthumbnail,exrthumbnail,directorythumbnail,fontthumbnail,imagethumbnail,jpegthumbnail,kraorathumbnail,windowsexethumbnail,windowsimagethumbnail,mobithumbnail,opendocumentthumbnail,gsthumbnail,rawthumbnail,svgthumbnail,ffmpegthumbs";
          };
          "kactivitymanagerdrc" = {
            "activities"."dad1e87e-84fb-4f4e-aa0f-cb086bfb65a6" = "Default";
            "main"."currentActivity" = "dad1e87e-84fb-4f4e-aa0f-cb086bfb65a6";
          };
          "kcminputrc" = {
            "Libinput/0/0/DP-3"."PointerAcceleration" = 0.000;
            "Libinput/1133/45108/Logitech MX Master 3S"."PointerAcceleration" = "-0.800";
            "Libinput/1133/50509/Logitech USB Receiver"."PointerAcceleration" = "-1.000";
            "Libinput/1133/50509/Logitech USB Receiver"."ScrollFactor" = 1.5;
            "Libinput/12951/6505/ZSA Technology Labs Moonlander Mark I"."PointerAcceleration" = 0.000;
            "Libinput/12972/24/Framework Laptop 16 Keyboard Module - ISO Consumer Control"."ScrollFactor" = 0.1;
            "Libinput/2362/628/PIXA3854:00 093A:0274 Mouse"."PointerAcceleration" = 0.000;
            "Libinput/2362/628/PIXA3854:00 093A:0274 Touchpad"."Enabled" = true;
            "Libinput/2362/628/PIXA3854:00 093A:0274 Touchpad"."ScrollFactor" = 0.5;
          };
          "kded5rc" = {
            "Module-browserintegrationreminder"."autoload" = false;
            "Module-device_automounter"."autoload" = false;
          };
          "kdeglobals" = {
            "DirSelect Dialog"."DirSelectDialog Size" = "818,574";
            "KDE"."ShowDeleteCommand" = false;
            "KFileDialog Settings"."Allow Expansion" = false;
            "KFileDialog Settings"."Automatically select filename extension" = true;
            "KFileDialog Settings"."Breadcrumb Navigation" = true;
            "KFileDialog Settings"."Decoration position" = 2;
            "KFileDialog Settings"."LocationCombo Completionmode" = 5;
            "KFileDialog Settings"."PathCombo Completionmode" = 5;
            "KFileDialog Settings"."Show Bookmarks" = false;
            "KFileDialog Settings"."Show Full Path" = false;
            "KFileDialog Settings"."Show Inline Previews" = true;
            "KFileDialog Settings"."Show Preview" = false;
            "KFileDialog Settings"."Show Speedbar" = true;
            "KFileDialog Settings"."Show hidden files" = false;
            "KFileDialog Settings"."Sort by" = "Name";
            "KFileDialog Settings"."Sort directories first" = true;
            "KFileDialog Settings"."Sort hidden files last" = false;
            "KFileDialog Settings"."Sort reversed" = false;
            "KFileDialog Settings"."Speedbar Width" = 140;
            "KFileDialog Settings"."View Style" = "DetailTree";
            "PreviewSettings"."MaximumRemoteSize" = 0;
            "WM"."activeBackground" = "49,54,59";
            "WM"."activeBlend" = "252,252,252";
            "WM"."activeForeground" = "252,252,252";
            "WM"."inactiveBackground" = "42,46,50";
            "WM"."inactiveBlend" = "161,169,177";
            "WM"."inactiveForeground" = "161,169,177";
          };
          "kiorc" = {
            "Confirmations"."ConfirmDelete" = true;
            "Confirmations"."ConfirmEmptyTrash" = true;
            "Confirmations"."ConfirmTrash" = false;
            "Executable scripts"."behaviourOnLaunch" = "alwaysAsk";
          };
          "kscreenlockerrc" = {
            "Daemon"."Autolock" = false;
          };
          "kservicemenurc" = {
            "Show"."compressfileitemaction" = true;
            "Show"."extractfileitemaction" = true;
            "Show"."forgetfileitemaction" = true;
            "Show"."installFont" = true;
            "Show"."kactivitymanagerd_fileitem_linking_plugin" = true;
            "Show"."kio-admin" = true;
            "Show"."makefileactions" = true;
            "Show"."mountisoaction" = true;
            "Show"."runInKonsole" = true;
            "Show"."slideshowfileitemaction" = true;
            "Show"."tagsfileitemaction" = true;
            "Show"."wallpaperfileitemaction" = true;
          };
          "kwalletrc" = {
            "Wallet"."First Use" = false;
          };
          "kwinrc" = {
            "Desktops"."Id_1" = "012e596c-77fb-4e52-915e-e18b3f10b2cb";
            "Desktops"."Number" = 1;
            "Desktops"."Rows" = 1;
            "Tiling"."padding" = 4;
            "Tiling/221d553c-9248-5af3-bc6a-f903ece85bd5"."tiles" =
              "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
            "Tiling/2ac20889-2ffe-5be7-9f82-671d80d0b6d7"."tiles" =
              "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
            "Tiling/63778347-f66a-5bb1-836c-0160bb0eba65"."tiles" =
              "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
            "Tiling/856e82be-9c6c-5a56-91d7-2e88fdb4e584"."tiles" =
              "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
            "Tiling/b139d5e7-0994-57d9-b378-1e6f13020bc3"."tiles" =
              "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
            "Tiling/c8a4a66d-bbca-5e7f-8a37-ce3b4a705568"."tiles" =
              "{\"layoutDirection\":\"horizontal\",\"tiles\":[{\"width\":0.25},{\"width\":0.5},{\"width\":0.25}]}";
            "Xwayland"."Scale" = 1.75;
          };
          "plasma-localerc" = {
            "Formats"."LANG" = "en_US.UTF-8";
          };
          "plasmanotifyrc" = {
            "Applications/discord"."Seen" = true;
          };
        };
      };
    };
}
