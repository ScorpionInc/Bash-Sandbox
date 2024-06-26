#!/bin/bash
voices=( ./piper_voices/*.onnx )
echo "Using first voice at path: ${voices[0]}"
while IFS=$'\n' read -r line; do
    echo "$line" | ./piper --model "${voices[0]}" --output_raw | aplay -f S16_LE -c1 -r22050 -t raw -
done

