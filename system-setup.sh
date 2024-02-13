#!/bin/bash
HERE=$(cd "$(dirname "$BASH_SOURCE")"; cd -P "$(dirname "$(readlink "$BASH_SOURCE" || echo .)")"; pwd)
ME="$(basename "$0")"
if [ "${HERE:0-1}" != "/" ];
then
	HERE+='/';
fi
if [ $(id -u) -ne 0 ]
  then echo "[ERROR]: '$HERE$ME' requires to be run as root."
  exit
fi
# Handle script parameters
isInteractive=1
while test $# -gt 0
do
    case "$1" in
        --quiet | --silent | --noninteractive) isInteractive=0
            ;;
        --*) echo "bad option $1"
            ;;
        *) echo "bad argument $1"
            ;;
    esac
    shift
done
while [ "$isInteractive" == "1" ]
do
	echo "This script will add and remove packages, may break things.";
	read -p "Would you like to continue? (Y/n): " promptResponse
	case $promptResponse in
		[nN] )
			exit
			;;
	esac
	case $promptResponse in
		[yY] )
			break
			;;
	esac
done
echo "Updating current source/repo listings..."
apt-get update -y
echo "Installing apt packages via secret cow powers."
apt-get install -y proxychains sshpass putty python3-full python3-pip
apt-get install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
echo "Script has completed."