#!/bin/env bash
echo Start of script
for i in {0..255..1}; do
	printf "\e[%dmANSI code: %d\e[0m\n" "$i" "$i"
done
echo End of script
