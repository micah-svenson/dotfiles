unclutter &
[[ -f ~/.Xmodmap ]] && xmodmap ~/.Xmodmap
setxkbmap -option caps:escape
xrdb ~/.Xresources
picom -b
exec i3
