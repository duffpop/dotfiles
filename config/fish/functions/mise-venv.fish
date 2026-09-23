function mise-venv --description 'Configures a local mise-en-place (former rtx) Python with a virtual environment' --argument python_version

    if test -e .mise.toml
        echo -s \
            (set_color $fish_color_error) \
            'File .mise.toml already exists; Better to edit it manually' \
            (set_color normal)
        return
    end

    if test -n "$python_version"
        echo -ne '[tools]\npython = {version="'$python_version'", virtualenv=".venv"}\n' > .mise.toml
    else
        echo -ne '[tools]\npython = {version="latest", virtualenv=".venv"}\n' > .mise.toml
    end
end
