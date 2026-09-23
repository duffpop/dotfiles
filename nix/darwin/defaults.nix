# macOS personalisation, captured from this Mac's current settings.
# Typed nix-darwin options where they exist; everything else goes through
# CustomUserPreferences (`defaults write`) or the currentHost script at the bottom.
# To find the key for a setting you change in System Settings: `dot watch-defaults`.
{
  lib,
  user,
  switchWarnings,
  ...
}:
let
  # Every prefs/<domain>.json (captured with `dot capture <domain> [key]`) is
  # written to that defaults domain on switch.
  captured = lib.mapAttrs' (
    file: _:
    lib.nameValuePair (lib.removeSuffix ".json" file) (builtins.fromJSON (builtins.readFile (./prefs + "/${file}")))
  ) (lib.filterAttrs (name: type: type == "regular" && lib.hasSuffix ".json" name) (builtins.readDir ./prefs));

  warnings = switchWarnings;
in
{
  system.defaults = {
    NSGlobalDomain = {
      # Keyboard
      InitialKeyRepeat = 10;
      KeyRepeat = 2;
      ApplePressAndHoldEnabled = false; # key repeat instead of accent popup
      AppleKeyboardUIMode = 3; # full keyboard access (Tab through all controls)
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = true;

      # Trackpad / mouse
      "com.apple.mouse.tapBehavior" = 1; # tap to click
      "com.apple.trackpad.forceClick" = false;
      "com.apple.trackpad.scaling" = 2.0; # tracking speed
      "com.apple.swipescrolldirection" = true; # natural scrolling
      "com.apple.springing.enabled" = true;
      "com.apple.springing.delay" = 0.5;

      # Appearance & windows
      AppleInterfaceStyleSwitchesAutomatically = true; # auto light/dark
      AppleFontSmoothing = 1;
      AppleShowAllExtensions = true;
      NSAutomaticWindowAnimationsEnabled = false;
      NSWindowResizeTime = 1.0e-3;
      NSTableViewDefaultSizeMode = 1; # small sidebar icons
      NSTextShowsControlCharacters = true;
      NSNavPanelExpandedStateForSaveMode = true;
      PMPrintingExpandedStateForPrint = true;
    };

    dock = {
      autohide = true;
      autohide-time-modifier = 0.6;
      orientation = "right";
      tilesize = 36;
      mineffect = "suck";
      minimize-to-application = true;
      launchanim = false;
      showhidden = true; # translucent icons for hidden apps
      show-process-indicators = true;
      enable-spring-load-actions-on-all-items = true;
      mru-spaces = false; # don't rearrange Spaces by recent use
      wvous-br-corner = 1; # bottom-right hot corner: disabled (default is Quick Note)
      persistent-apps = [
        "/System/Volumes/Preboot/Cryptexes/App/System/Applications/Safari.app"
        "/System/Applications/Notes.app"
        "/System/Applications/Siri AI.app"
        "/System/Applications/System Settings.app"
      ];
    };

    finder = {
      FXPreferredViewStyle = "Nlsv"; # list view
      FXDefaultSearchScope = "SCcf"; # search the current folder
      FXEnableExtensionChangeWarning = false;
      FXRemoveOldTrashItems = true; # empty Trash after 30 days
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
      QuitMenuItem = true;
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = true;
      ShowMountedServersOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
    };

    trackpad = {
      Clicking = true; # tap to click
      TrackpadRightClick = true;
      TrackpadCornerSecondaryClick = 0;
      TrackpadThreeFingerDrag = true;
      Dragging = false;
      DragLock = false;
      FirstClickThreshold = 1;
      SecondClickThreshold = 1;
      ActuateDetents = true;
      ForceSuppressed = false;
      TrackpadThreeFingerTapGesture = 0; # look up: off
      TrackpadThreeFingerHorizSwipeGesture = 0; # three fingers are used for dragging,
      TrackpadThreeFingerVertSwipeGesture = 0; # so swipes use four fingers
      TrackpadFourFingerHorizSwipeGesture = 2;
      TrackpadFourFingerVertSwipeGesture = 2;
      TrackpadFourFingerPinchGesture = 2;
      TrackpadMomentumScroll = true;
      TrackpadPinch = true;
      TrackpadRotate = true;
      TrackpadTwoFingerDoubleTapGesture = true; # smart zoom
      TrackpadTwoFingerFromRightEdgeSwipeGesture = 3; # Notification Centre
    };

    magicmouse.MouseButtonMode = "OneButton";

    WindowManager = {
      EnableStandardClickToShowDesktop = false; # click wallpaper: only in Stage Manager
      EnableTilingByEdgeDrag = false;
      EnableTopTilingByEdgeDrag = false;
      EnableTilingOptionAccelerator = false;
      EnableTiledWindowMargins = false;
      HideDesktop = true;
      StandardHideWidgets = false;
      StageManagerHideWidgets = false;
      AppWindowGroupingBehavior = true;
      AutoHide = false;
    };

    menuExtraClock = {
      ShowAMPM = true;
      ShowDate = 0; # when space allows
      ShowDayOfWeek = true;
      ShowSeconds = true;
    };

    screencapture.disable-shadow = true;
    screensaver = {
      askForPassword = true;
      askForPasswordDelay = 0;
    };
    hitoolbox.AppleFnUsageType = "Do Nothing"; # globe/fn key
    ActivityMonitor = {
      ShowCategory = 102; # my processes
      OpenMainWindow = true;
    };

    CustomUserPreferences = lib.recursiveUpdate captured {
      NSGlobalDomain = {
        KeyRepeatDelay = "0.1";
        AppleAntiAliasingThreshold = 2;
        AppleMiniaturizeOnDoubleClick = false;
        NSQuitAlwaysKeepsWindows = false;
        "com.apple.trackpad.scrolling" = 0.4412; # scroll speed
        "com.apple.sound.beep.flash" = 0;
        # Smart quotes style
        KB_DoubleQuoteOption = "“abc”";
        KB_SingleQuoteOption = "‘abc’";
        NSUserQuotesArray = [
          "“"
          "”"
          "‘"
          "’"
        ];
        # List view in open/save dialogs
        NSNavPanelFileLastListModeForOpenModeKey = 2;
        NSNavPanelFileLastListModeForSaveModeKey = 2;
        NSNavPanelFileListModeForOpenMode2 = 2;
        NSNavPanelFileListModeForSaveMode2 = 2;
        NavPanelFileListModeForOpenMode = 2;
        NavPanelFileListModeForSaveMode = 2;
        shouldShowRSVPDataDetectors = false;
        WebKitDeveloperExtras = true;
      };
      "com.apple.finder" = {
        DisableAllAnimations = true;
        QLEnableTextSelection = true;
        WarnOnEmptyTrash = false;
        FXArrangeGroupViewBy = "Name";
      };
      "com.apple.desktopservices".DSDontWriteNetworkStores = true;
      "com.apple.loginwindow" = {
        TALLogoutSavesState = false; # don't reopen windows at login
        LoginwindowLaunchesRelaunchApps = false;
      };
      "com.apple.screencapture" = {
        target-screenshot = "file";
        target-screenrecording = "file";
      };
      "com.apple.controlcenter" = {
        "NSStatusItem VisibleCC Battery" = true;
        "NSStatusItem VisibleCC BentoBox-0" = true;
        "NSStatusItem VisibleCC Clock" = true;
        "NSStatusItem VisibleCC Display" = true;
        "NSStatusItem VisibleCC FocusModes" = true;
        "NSStatusItem VisibleCC ScreenMirroring" = true;
        "NSStatusItem VisibleCC WiFi" = true;
      };
      "com.apple.TextInputMenu".visible = false; # hide input menu in menu bar
      "com.apple.Siri".StatusMenuVisible = true;
      "com.apple.AppleMultitouchMouse" = {
        MouseButtonDivision = 55;
        MouseHorizontalScroll = true;
        MouseMomentumScroll = true;
        MouseVerticalScroll = true;
        MouseOneFingerDoubleTapGesture = 0;
        MouseTwoFingerDoubleTapGesture = 3;
        MouseTwoFingerHorizSwipeGesture = 2;
      };
      "com.apple.frameworks.diskimages" = {
        auto-open-ro-root = true;
        auto-open-rw-root = true;
        skip-verify = true;
        skip-verify-locked = true;
        skip-verify-remote = true;
      };
      "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
      "com.apple.AdLib".allowApplePersonalizedAdvertising = false;
      "com.apple.iTunes".NSUserKeyEquivalents."Target Search Field" = "@F";
    };
  };

  # Writes nix-darwin's own defaults step can't do, run so that a failure is
  # logged to ${warnings} instead of aborting the whole activation:
  #  - com.apple.universalaccess is privacy-protected: writing it needs Full
  #    Disk Access for the terminal running `dot switch`.
  #  - "ByHost" (-currentHost) settings, which the typed options can't target.
  system.activationScripts.postActivation.text = ''
    echo >&2 "tolerant user defaults..."
    asUser() { launchctl asuser "$(id -u -- ${user.name})" sudo --user=${user.name} -- "$@"; }
    asUser mkdir -p "$(dirname ${warnings})"
    try() { # try <hint> <command...>
      local hint="$1" out
      shift
      if ! out="$(asUser "$@" 2>&1)"; then
        printf 'macOS setting not applied: %s\n  %s\n  fix: %s\n' "$*" "$out" "$hint" |
          tee -a ${warnings} >&2
      fi
    }
    fda="System Settings > Privacy & Security > Full Disk Access: enable your terminal, then run 'dot'"
    try "$fda" defaults write com.apple.universalaccess reduceMotion -bool true
    try "$fda" defaults write com.apple.universalaccess reduceTransparency -bool true
    try "$fda" defaults write com.apple.universalaccess increaseContrast -bool true

    host="re-run 'dot'; if it persists, check the key with 'dot watch-defaults'"
    try "$host" defaults -currentHost write -g NSStatusItemSpacing -int 10
    try "$host" defaults -currentHost write -g NSStatusItemSelectionPadding -int 10
    try "$host" defaults -currentHost write -g com.apple.mouse.tapBehavior -int 1
    try "$host" defaults -currentHost write -g com.apple.trackpad.enableSecondaryClick -bool true
    try "$host" defaults -currentHost write -g com.apple.trackpad.threeFingerDragGesture -bool true
    try "$host" defaults -currentHost write -g com.apple.trackpad.threeFingerTapGesture -int 0
    try "$host" defaults -currentHost write -g com.apple.trackpad.threeFingerHorizSwipeGesture -int 0
    try "$host" defaults -currentHost write -g com.apple.trackpad.threeFingerVertSwipeGesture -int 0
    try "$host" defaults -currentHost write -g com.apple.trackpad.fourFingerHorizSwipeGesture -int 2
    try "$host" defaults -currentHost write -g com.apple.trackpad.fourFingerVertSwipeGesture -int 2
    try "$host" defaults -currentHost write -g com.apple.trackpad.fourFingerPinchSwipeGesture -int 2
    try "$host" defaults -currentHost write -g com.apple.trackpad.fiveFingerPinchSwipeGesture -int 2
    try "$host" defaults -currentHost write -g com.apple.trackpad.twoFingerDoubleTapGesture -int 1
    try "$host" defaults -currentHost write -g com.apple.trackpad.twoFingerFromRightEdgeSwipeGesture -int 3
    try "$host" defaults -currentHost write com.apple.controlcenter BatteryShowPercentage -bool true
    try "$host" defaults -currentHost write com.apple.controlcenter Display -int 16
    try "$host" defaults -currentHost write com.apple.controlcenter FocusModes -int 16
    try "$host" defaults -currentHost write com.apple.controlcenter ScreenMirroring -int 16

    # Apply keyboard-shortcut and keyboard changes without logging out.
    try "log out and back in" /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    killall -qu ${user.name} SystemUIServer ControlCenter Finder || true
  '';
}
