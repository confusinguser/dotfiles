#!/bin/bash

case $(( $RANDOM % 4 )) in
# case 3 in
  0) colors=("5EB1BF" "042A2BCC" "EF7B45") # Surfer's colors
    ;;
  1) colors=("8C2F39" "461220CC" "FCB8B0") # Hot incinerator
    ;;
  2) colors=("7A308C" "321245DD" "EE81EE") # Bottom of the rainbow
    ;;
  3) colors=("18A300" "102B04CC" "1983E0") # Cactus flower
    ;;
  # 4) colors=("308C36" "174512CC" "2FC657") # Ugly green
  #   ;;
esac

args="--clock --indicator --effect-blur 5x10 --fade-in 0.2 --ring-color ${colors[0]} --effect-vignette 0.5:0.5 --inside-color ${colors[1]} --text-color ${colors[2]} "

if [ $# == 0 ] || [ $0 != "--image" ]
then
  swaylock ${args} --screenshots --effect-scale 1.1 --scaling center $@
else
  swaylock ${args} $@
fi
