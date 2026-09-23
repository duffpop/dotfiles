function preview_recent_files
    ls -t | head -n 10 | fzf --preview 'bat --style=numbers --color=always --line-range :500 {}'
end
