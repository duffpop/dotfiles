# Linux-only home config (Ubuntu/Debian desktop). GUI apps are installed
# natively by linux/apps.sh (`dot apps`), not by Nix.
{ pkgs, user, ... }:
{
  home.username = user.name;
  home.homeDirectory = "/home/${user.name}";

  programs.home-manager.enable = true;
  targets.genericLinux.enable = true; # XDG_DATA_DIRS, locales, etc. on non-NixOS

  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    monaspace
    nerd-fonts.monaspace
    codex # on macOS this comes from the `codex` cask
    wl-clipboard
  ];

  # bash stays the login shell; interactive sessions hand over to fish
  # (same behaviour as macOS, where Ghostty launches fish on top of zsh).
  programs.bash = {
    enable = true;
    initExtra = ''
      if [[ $(ps --no-header --pid=$PPID --format=comm) != "fish" && -z ''${BASH_EXECUTION_STRING} && ''${SHLVL} == 1 ]]; then
        shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
        exec ${pkgs.fish}/bin/fish $LOGIN_OPTION
      fi
    '';
  };
}
