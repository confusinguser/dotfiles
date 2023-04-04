if status is-interactive
    starship init fish | source
    cat ~/dotfiles/.aliases | source
    zoxide init fish --cmd cd | source
end
set fish_greeting

function fish_user_key_bindings
    bind \cH backward-kill-word
    bind § accept-autosuggestion
    bind \cs backward-kill-line
end
