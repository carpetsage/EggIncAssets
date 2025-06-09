#!/usr/bin/env zsh
force=0
[[ $1 == -f || $1 == --force ]] && force=1

# Detect which ImageMagick command is available
if command -v magick >/dev/null 2>&1; then
    MAGICK_CMD="magick"
elif command -v convert >/dev/null 2>&1; then
    MAGICK_CMD="convert"
else
    echo "ERROR: Neither 'magick' nor 'convert' command found. Please install ImageMagick."
    exit 1
fi

for size in 32 64 128 256; do
    mkdir -p $size/egginc $size/egginc-extras $size/egginc-extras/glow
done
for src in orig/egginc/*.png orig/egginc-extras/**/*.png; do
    dst=$src:r.webp
    ((( force )) || [[ ! -e $dst ]]) && {
        echo "$src => $dst"
        $MAGICK_CMD $src -define webp:lossless=true $dst
    }
    for size in 32 64 128 256; do
        dst=${size}/${src#orig/}
        ((( force )) || [[ ! -e $dst ]]) && {
            echo "$src => $dst"
            $MAGICK_CMD $src -resize ${size}x${size} $dst
            optipng -quiet $dst
        }
        dst=$dst:r.webp
        ((( force )) || [[ ! -e $dst ]]) && {
            echo "$src => $dst"
            $MAGICK_CMD $src -resize ${size}x${size} $dst
        }
    done
done
