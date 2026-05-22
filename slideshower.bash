#!/bin/bash

function slideshower() {
    local target_dir="${1:-.}"
    feh --geometry +0+0 --recursive --randomize --auto-zoom --fullscreen --draw-filename --draw-tinted "$target_dir"
}
