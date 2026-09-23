function nf --wraps='nvim /fish/config.fish' --wraps='nvim $HOME/.config/fish/config.fish' --description 'alias nf=nvim $HOME/.config/fish/config.fish'
  nvim $HOME/.config/fish/config.fish $argv
        
end
