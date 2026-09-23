# macOS-only packages: GUI apps (casks), Mac App Store apps, and the few CLI
# tools that aren't in nixpkgs. Every other CLI tool lives in nix/home/packages.nix
# so macOS and Linux share one list.
{ ... }:
{
  homebrew = {
    enable = true;
    onActivation = {
      # Switches stay fast and offline-safe; `dot update` upgrades explicitly.
      autoUpdate = false;
      upgrade = false;
      # "none": anything installed but not listed here is left alone.
      # Once the list is complete, change to "uninstall" (or "zap") to make this
      # file authoritative; `dot drift` shows what would be removed.
      cleanup = "none";
    };

    taps = [
      "as-foss/mandible"
      "domt4/autoupdate"
      "nikitabobko/tap"
    ];

    brews = [
      "mandible"
      "quien"
      "taproom"
      "gcc"
      "mas" # needed for masApps below
    ];

    casks = [
      # Terminals, editors & dev tools
      "ghostty"
      "warp"
      "visual-studio-code@insiders"
      "orbstack"
      "claude-code@latest"
      "codex"
      "gcloud-cli"
      "xcodes-app"
      "homebrew-app"
      "imazing-profile-editor"
      "pppc-utility"
      "mist"
      "crystalfetch"
      "utm"
      "parallels"

      # Window management, input & menu bar
      "nikitabobko/tap/aerospace"
      "omniwm"
      "alt-tab"
      "rectangle-pro"
      "homerow"
      "karabiner-elements"
      "raycast"
      "betterdisplay"
      "stats"
      "thaw@beta"
      "shottr"

      # Browsers
      "arc"
      "zen"
      "helium-browser"

      # Apps
      "1password@beta"
      "1password-cli@beta"
      "chatgpt"
      "claude"
      "ente-auth"
      "granola"
      "linear"
      "notion"
      "notion-calendar"
      "obsidian"
      "okta-verify"
      "setapp"
      "slack"
      "spotify"
      "tailscale-app"
      "vorssaint"
      "whatsapp@beta"
      "xum"
      "zoom"

      # Fonts
      "font-monaspace"
      "font-monaspace-nf"
      "font-monaspace-var"
    ];

    masApps = {
      GarageBand = 682658836;
      iMovie = 408981434;
      Keynote = 409183694;
      NextDNS = 1464122853;
      Numbers = 409203825;
      Pages = 409201541;
      Parcel = 375589283;
      Xcode = 497799835;
    };
  };
}
