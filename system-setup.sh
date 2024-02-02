#!/bin/bash
HERE=$(cd "$(dirname "$BASH_SOURCE")"; cd -P "$(dirname "$(readlink "$BASH_SOURCE" || echo .)")"; pwd)
ME="$(basename "$0")"
if [ "${HERE:0-1}" != "/" ];
then
	HERE+='/';
fi
if [ $(id -u) -ne 0 ]
  then echo "Script: '$HERE$ME' requires to be run as root."
  exit
fi
apt-get update
apt-get install proxychains sshpass putty
