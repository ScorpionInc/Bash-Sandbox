#!/usr/bin/env bash
# Modified from source:
# https://stackoverflow.com/a/54101920
temprepo=$(mktemp -d "$BASH_SOURCE".XXXXXX)
tempfile=$(mktemp "$BASH_SOURCE".XXXXXX)
echo "$temprepo $tempfile"
rm -f "$tempfile"
time git clone --no-checkout --depth 1 https://github.com/ScorpionInc/Bash-Sandbox.git "$temprepo"
profileHashes=$(git -C "$temprepo" ls-tree --full-name --name-only -r HEAD | grep -E '^Profile[/\]+.*[.]sha512$')
profileHash=$(echo "$profileHashes" | cut -c 9-)
profileFile=${profileHash%.*}
echo "$profileFile"
curl "https://raw.githubusercontent.com/ScorpionInc/Bash-Sandbox/main/Profile/$profileHash"
rm -rf "$temprepo"
