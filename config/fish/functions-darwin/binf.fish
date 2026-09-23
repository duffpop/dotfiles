function binf --wraps='brew info --verbose' --description 'alias binf=brew info --verbose'
  brew info --verbose $argv
        
end
