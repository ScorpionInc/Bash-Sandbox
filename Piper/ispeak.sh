#!/bin/bash
voices=( ./piper_voices/*-high.onnx )
echo "Using first voice at path: ${voices[0]}"
while IFS= read -rp "What do you want to say?: " line; do
	[ -z "$line" ] && break;
	(echo "$line" | ./piper --model "${voices[0]}" --output_raw 2>/dev/null | aplay -f S16_LE -c1 -r22050 -t raw - &>/dev/null 2>&1)&
done

