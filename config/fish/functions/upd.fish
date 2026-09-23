function upd --description 'Update the OS, dotfiles packages and mise tools'
    switch (uname)
        case Darwin
            softwareupdate -i -a
        case Linux
            sudo apt update && sudo apt upgrade -y
            type -q flatpak; and flatpak update -y
            type -q snap; and sudo snap refresh
    end
    dot update
    mise up --bump
end
