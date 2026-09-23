# macOS-only home config.
{ config, pkgs, dot, ... }:
{
  home.packages = with pkgs; [
    coreutils-prefixed # GNU coreutils as g* (gls, gdate, ...) so BSD tools keep working
    jankyborders
    pinentry_mac
  ];

  xdg.configFile = dot.linkEach "fish/functions-darwin" "fish/functions" // {
    "karabiner".source = dot.link "karabiner";
    "omniwm".source = dot.link "omniwm";
    "borders".source = dot.link "borders";
  };

  home.file = {
    ".zprofile".source = dot.link "zsh/zprofile";
    ".zshenv".source = dot.link "zsh/zshenv";
    # Same agent socket path as Linux, so SSH_AUTH_SOCK/ssh config are portable.
    ".1password/agent.sock".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock";
  };
}
