if status is-interactive
    starship init fish | source
    alias ls='exa -a -1 -l --group-directories-first --git --no-user -h'
end
set fish_greeting
export EDITOR='/usr/bin/nvim'
export VISUAL='/usr/bin/nvim'
