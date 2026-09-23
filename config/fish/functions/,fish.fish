function ,fish --wraps='cd ' --wraps='cd $HOME/.config/fish/' --description 'alias ,conf=cd $HOME/.config/'
    cd $HOME/.config/fish/ $argv
end
