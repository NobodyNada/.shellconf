#!/bin/bash

set -e

OLD=( ~/.local/share/wallpaper.*.jpg )
OUT=~/.local/share/wallpaper.$(date +%s).jpg
wcurl -o "$OUT" https://cdn.star.nesdis.noaa.gov/GOES19/ABI/CONUS/GEOCOLOR/5000x3000.jpg
plasma-apply-wallpaperimage "$OUT"
rm "${OLD[@]}" || true
