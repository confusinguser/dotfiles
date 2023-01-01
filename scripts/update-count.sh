#!/usr/bin/sh

upgradable=$(yay -Qu | wc -l)

if [ upgradable=="0" ]; then
        echo $(yay -Q | wc -l)
else
        echo $upgradable/$(yay -Q | wc -l)
fi
