if status is-interactive
    starship init fish | source
    cat ~/dotfiles/.aliases | source
    zoxide init fish --cmd cd | source
end
set fish_greeting
