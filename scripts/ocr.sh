#!/bin/bash

IMAGE=$(mktemp /tmp/ocr-shot-XXXX.png)
grim -g "$(slurp)" "$IMAGE"
tesseract "$IMAGE" stdout | wl-copy
notify-send "OCR" "Text copied to clipboard!"
rm "$IMAGE"

