function reload --description 'Restart fish as a login shell'
    exec fish -l $argv
end
