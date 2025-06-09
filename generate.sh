#!/usr/bin/env zsh
# set -e  # Exit on any error
# set -x  # Print commands as they execukte

force=0
[[ $1 == -f || $1 == --force ]] && force=1

echo "Creating directories..."
for size in 32 64 128 256; do
    mkdir -p $size/egginc $size/egginc-extras $size/egginc-extras/glow
done

echo "Processing files..."
for src in orig/egginc/*.png orig/egginc-extras/**/*.png; do
    echo "Processing: $src"

    # Check if file exists (in case glob doesn't match anything)
    if [[ ! -f "$src" ]]; then
        echo "File does not exist: $src"
        continue
    fi

    dst=$src:r.webp
    ((( force )) || [[ ! -e $dst ]]) && {
        echo "Creating WebP: $src => $dst"
        if ! magick "$src" -define webp:lossless=true "$dst"; then
            echo "ERROR: magick failed for WebP conversion: $src"
            exit 1
        fi
    }

    for size in 32 64 128 256; do
        dst=${size}/${src#orig/}
        ((( force )) || [[ ! -e $dst ]]) && {
            echo "Resizing PNG: $src => $dst (${size}x${size})"
            if ! magick "$src" -resize ${size}x${size} "$dst"; then
                echo "ERROR: magick failed for PNG resize: $src"
                exit 1
            fi
            echo "Optimizing PNG: $dst"
            if ! optipng -quiet "$dst"; then
                echo "ERROR: optipng failed for: $dst"
                exit 1
            fi
        }
        dst=$dst:r.webp
        ((( force )) || [[ ! -e $dst ]]) && {
            echo "Creating resized WebP: $src => $dst (${size}x${size})"
            if ! magick "$src" -resize ${size}x${size} "$dst"; then
                echo "ERROR: magick failed for WebP resize: $src"
                exit 1
            fi
        }
    done
done

echo "Script completed successfully!"
