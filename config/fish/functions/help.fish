function help
    eval (string join ' ' $argv) --help 2>/dev/stdout | bathelp
end
