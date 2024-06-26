#!/bin/bash
echo Installing Piper TTS
# https://github.com/rhasspy/piper
echo Some steps may require elevated permissions.
echo
echo Clearing the stage...
echo
rm -f ./piper_amd64.tar 2>/dev/null
rm -f ./piper_amd64.tar.gz 2>/dev/null
echo Installing pre-req packages
echo
sudo apt-get update && sudo apt-get install curl jq gzip espeak
if ! test -f ./piper; then
	echo "Fetching the latest release's compressed archive from github.com via cURL"
	echo
	rm -rf ./piper/ 2>/dev/null
	curl -sL https://api.github.com/repos/rhasspy/piper/tags | jq -r '.[0].zipball_url' | egrep -o "[/][^/]*$" | xargs -I {} -n 1 curl --output 'piper_amd64.tar.gz' -sL 'https://github.com/rhasspy/piper/releases/download{}/piper_amd64.tar.gz'
	gunzip ./piper_amd64.tar.gz && tar -xf ./piper_amd64.tar
	rm -f ./piper_amd64.tar
	mv -f ./piper/ ./piper_amd64/
	ln -s ./piper_amd64/piper ./piper
fi
if ! test -d ./piper_voices; then
	echo "Fetching all Voices(English)"
	echo
	# https://github.com/jaywalnut310/vits/
	mkdir ./piper_voices/ 2>/dev/null
	(cd ./piper_voices/ && curl -sL 'https://raw.githubusercontent.com/rhasspy/piper/master/VOICES.md' | egrep -o '[(]http[^()]*[)]' | egrep -o 'http.*true' | egrep -i 'en_(US|GB)' | xargs -I {} -n 1 curl -sOL '{}')
fi
echo Running Diagnostic Test
echo
voices=( ./piper_voices/*.onnx )
echo "Using first voice at path: ${voices[0]}"
echo 'This is an example message used to test Piper. Hello World!' | ./piper --model "${voices[0]}" --output_raw | aplay -f S16_LE -c1 -r22050 -t raw -
#--speaker 0
echo
echo Script has completed.
