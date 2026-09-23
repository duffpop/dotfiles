{ pkgs, user, ... }:
{
  imports = [
    ./defaults.nix
    ./homebrew.nix
  ];

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Nix itself is installed and managed by the Determinate installer, so
  # nix-darwin must not manage the daemon or nix.conf.
  nix.enable = false;

  system.primaryUser = user.name;
  system.stateVersion = 6;
  users.users.${user.name}.home = "/Users/${user.name}";

  # zsh stays the login shell; nix-darwin writes /etc/zshrc so it sees Nix paths.
  programs.zsh.enable = true;
  # Writes /etc/fish so the Nix fish that Ghostty launches gets Nix paths.
  programs.fish.enable = true;
  environment.shells = [ pkgs.fish ];

  # Touch ID for sudo (replaces the old add_touch_id.sh / tid function).
  security.pam.services.sudo_local.touchIdAuth = true;
}
