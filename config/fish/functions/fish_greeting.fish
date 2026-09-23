function fish_greeting
    set -l rand_num (math (random) / 32767 \* 100)
    if test $rand_num -lt 10
        tldr --quiet (tldr --quiet --list | shuf -n1)
    end
end
