#!/usr/bin/env zsh
set -x
force=0
[[ $1 == -f || $1 == --force ]] && force=1
for size in 32 64 128 256; do
    mkdir -p $size/egginc $size/egginc-extras $size/egginc-extras/glow
done
for src in orig/egginc/*.png orig/egginc-extras/**/*.png; do
    dst=$src:r.webp
    ((( force )) || [[ ! -e $dst ]]) && {
        echo "$src => $dst"
        magick $src -define webp:lossless=true $dst
    }
    for size in 32 64 128 256; do
        dst=${size}/${src#orig/}
        ((( force )) || [[ ! -e $dst ]]) && {
            echo "$src => $dst"
            magick $src -resize ${size}x${size} $dst
            optipng -quiet $dst
        }
        dst=$dst:r.webp
        ((( force )) || [[ ! -e $dst ]]) && {
            echo "$src => $dst"
            magick $src -resize ${size}x${size} $dst
        }
    done
done
