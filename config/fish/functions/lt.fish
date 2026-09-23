function lt --wraps=lsd
    if test (count $argv) -eq 0
        ls -lt | head -n 20
    else
        ls -lt | head -n $argv[1]
    end
end
