export STARSHIP_CONFIG="$HOME/.config/starship.toml"

source "$HOME/.config/fish/conf.d/abbreviations.fish"

test "$TERM" = xterm-ghostty; and test -e {$GHOSTTY_RESOURCES_DIR}/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish; and source {$GHOSTTY_RESOURCES_DIR}/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish

mise activate fish | source

# Homebrew (macOS: casks + a few tap-only tools). Nix-managed tools keep precedence.
if test -x /opt/homebrew/bin/brew
    /opt/homebrew/bin/brew shellenv | source
    fish_add_path --global --move --path /etc/profiles/per-user/$USER/bin /run/current-system/sw/bin
end

if status is-interactive

    ### Starship prompt ###
    function starship_transient_prompt_func
        starship module character
    end

    function starship_transient_rprompt_func
        starship module time
    end

    starship init fish | source
    enable_transience
    ### End Starship prompt ###

    # set HB_CNF_HANDLER (brew --repository)"/Library/Taps/homebrew/homebrew-command-not-found/handler.fish"
    # if test -f $HB_CNF_HANDLER
    #     source $HB_CNF_HANDLER
    # end

    if type -q brew
        set HOMEBREW_COMMAND_NOT_FOUND_HANDLER (brew --repository)/Library/Homebrew/command-not-found/handler.fish
        if test -f $HOMEBREW_COMMAND_NOT_FOUND_HANDLER
            source $HOMEBREW_COMMAND_NOT_FOUND_HANDLER
        end
    end

    fzf_configure_bindings --directory=\cf

    atuin init fish --disable-up-arrow | source
end

# export PATH="$PATH:$HOME/.local/bin"
set -gx SSH_AUTH_SOCK ~/.1password/agent.sock
# source /Users/haydenduffy/.config/op/plugins.sh

# Setting PATH for Python 3.12
# The original version is saved in /Users/haydenduffy/.config/fish/config.fish.pysave
# set -x PATH "/Library/Frameworks/Python.framework/Versions/3.12/bin" "$PATH"
# set -gx LC_ALL

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
test -f ~/.orbstack/shell/init.fish; and source ~/.orbstack/shell/init.fish

# OpenClaw Completion
# openclaw completion --shell fish | source
