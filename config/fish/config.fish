if status is-interactive
    starship init fish | source
    cat ~/.aliases | source
end
set fish_greeting
export EDITOR='/usr/bin/nvim'
export VISUAL='/usr/bin/nvim'
