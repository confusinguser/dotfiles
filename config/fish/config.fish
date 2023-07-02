if status is-login
    wrappedhl
end

if status is-interactive
    starship init fish | source
    cat ~/dotfiles/.aliases | source
    zoxide init fish --cmd cd | source
end
set fish_greeting

export PATH="~/.local/bin:$PATH"

function fish_user_key_bindings
    bind \cH backward-kill-path-component
    bind § accept-autosuggestion
    bind \cs backward-kill-line
    bind \es 'fish_commandline_prepend doas'
    bind \[3\;5~ kill-word
    bind -k backspace kill-selection or backward-delete-char
end
