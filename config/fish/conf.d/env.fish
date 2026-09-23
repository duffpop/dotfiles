# Environment shared by every machine. These used to be fish universal
# variables (fish_variables is machine-local state and is not tracked).
set -gx EDITOR nvim
set -gx LC_ALL en_GB.UTF-8
set -gx MANPAGER "sh -c 'col -bx | bat -l man -p'"
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx CONFIG_HOME $HOME/.config
set -gx GOPATH $HOME/go
set -gx PIPX_HOME $HOME/.local/share/pipx/
set -gx PACKER_PLUGIN_PATH $HOME/.config/packer/plugins
set -gx MISE_PYTHON_VENV_AUTO_CREATE true
set -gx NEXT_TELEMETRY_DISABLED 1
set -gx HOMEBREW_NO_ANALYTICS 1
set -gx HOMEBREW_AUTO_UPDATE_SECS 86400
set -gx HOMEBREW_XDG_CONFIG_HOME $HOME/.config

# zoxide.fish plugin: replace `cd` (must be set before conf.d/zoxide.fish loads)
set -g zoxide_cmd cd

fish_add_path --global $HOME/.local/bin $HOME/bin $HOME/.cargo/bin $GOPATH/bin
