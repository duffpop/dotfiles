# macOS-only packages: GUI apps (casks), Mac App Store apps, and the few CLI
# tools that aren't in nixpkgs. Every other CLI tool lives in nix/home/packages.nix
# so macOS and Linux share one list.
{
  config,
  lib,
  switchWarnings,
  ...
}:
let
  # Mac App Store installs need a signed-in Apple ID. Switched off while testing
  # in a VM that can't sign in; set back to true to install masApps again.
  installMasApps = false;
in
{
  homebrew = {
    enable = true;
    # Puts brew on PATH for every zsh via /etc/zshrc (independent of home-manager).
    # fish does its own setup in config/fish/config.fish so Nix tools keep precedence.
    enableZshIntegration = true;
    onActivation = {
      # Switches stay fast and offline-safe; `dot update` upgrades explicitly.
      autoUpdate = false;
      upgrade = false;
      # "none": anything installed but not listed here is left alone.
      # Once the list is complete, change to "uninstall" (or "zap") to make this
      # file authoritative; `dot drift` shows what would be removed.
      cleanup = "none";
    };

    # Homebrew 6+ refuses to load formulae/casks from third-party taps unless
    # they're trusted (HOMEBREW_REQUIRE_TAP_TRUST), which aborts `brew bundle`.
    taps = map (name: { inherit name; trusted = true; }) [
      "as-foss/mandible"
      "domt4/autoupdate"
      "nikitabobko/tap"
    ];

    brews = [
      "as-foss/mandible/mandible"
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
      "zoom"

      # Fonts
      "font-monaspace"
      "font-monaspace-nf"
      "font-monaspace-var"
    ];

    masApps = lib.optionalAttrs installMasApps {
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

  # nix-darwin runs `brew bundle` before the home-manager step, and by default a
  # single failing tap/cask aborts the whole activation (no dotfiles linked, the
  # new generation never becomes current). Run it tolerantly instead: a failure is
  # logged to the switch warnings that `dot` prints, and activation carries on.
  system.activationScripts.homebrew.text = lib.mkForce ''
    echo >&2 "Homebrew bundle..."
    if [ -f "${config.homebrew.prefix}/bin/brew" ]; then
      if ! ${config.homebrew.onActivation.brewBundleCmd { onlyCheck = false; }}; then
        printf '%s\n  %s\n' "Homebrew bundle failed: some apps/tools from nix/darwin/homebrew.nix may be missing" \
          "fix: see the brew output above, then run 'dot'" | tee -a ${switchWarnings} >&2
      fi
    else
      printf '%s\n' "Homebrew is not installed: skipped casks/brews; install it (bootstrap.sh does) and run 'dot'" |
        tee -a ${switchWarnings} >&2
    fi
  '';
}
