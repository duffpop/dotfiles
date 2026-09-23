function ping
    if count $argv >/dev/null
        command ping $argv
    else
        command ping 1.1.1.1
    end
end
