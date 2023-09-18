if [ -z "$DISPLAY" ] && [ "$(tty)" = /dev/tty1 ]
    export XDG_SESSION_DESKTOP=sway
    export XDG_CURRENT_DESKTOP=sway

    # Firefox
    export MOZ_ENABLE_WAYLAND=1

    # Qt5
    export XDG_SESSION_TYPE=wayland
    sway
end

if status is-interactive
    starship init fish | source
    cat ~/dotfiles/.aliases | source
    zoxide init fish --cmd cd | source
end

export PATH="/home/mk/.local/bin:$PATH"

function fish_user_key_bindings
    bind \cH backward-kill-path-component
    bind § accept-autosuggestion
    bind \cs backward-kill-line
    bind \es 'fish_commandline_prepend doas'
    bind \[3\;5~ kill-word
    bind -k backspace kill-selection or backward-delete-char
end
