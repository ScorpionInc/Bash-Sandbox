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
checkFile="~/.si-system-setup.checked"
autoPurged=("aisleriot" "brltty" "duplicity" "empathy" "empathy-call" "empathy-common" "example-content" "gnome-accessibility-themes" "gnome-contacts" "gnome-mahjongg" "gnome-mines" "gnome-orca" "gnome-screensaver" "gnome-sudoku" "gnome-video-effects" "landscape-common" "libsane" "libsane-common" "rhythmbox" "rhythmbox-plugins" "rhythmbox-plugin-zeitgeist" "sane-utils" "shotwell" "shotwell-common" "telepathy-gabble" "telepathy-haze" "telepathy-idle" "telepathy-indicator" "telepathy-logger" "telepathy-mission-control-5" "telepathy-salut" "totem" "totem-common" "totem-plugins" "printer-driver-brlaser" "printer-driver-foo2zjs" "printer-driver-foo2zjs-common" "printer-driver-m2300w" "printer-driver-ptouch" "printer-driver-splix")
autoInstallAPTBase=("htop" "flatpak" "libreoffice" "wget")
autoInstallDEBBase=()
# ufw nftable
autoInstallAPTWork=("proxychains" "sshpass" "putty" "python3-full" "python3-pip" "iptables" "wireshark" "tshark" "xxd" "openjdk-11-jdk" "docker" "curl")
autoInstallDEBWork=()
autoInstallAPTGame=("wine")
autoInstallDEBGame=()
isInteractive=1
#Base All Game Work
installType="Base"
while test $# -gt 0
do
    case "$1" in
        --quiet | --silent | --noninteractive) isInteractive=0
            ;;
		--work | --tools | --utils) installType="Work"
            ;;
		--game | --fun | --play) installType="Game"
            ;;
		--all | --everything | --full) installType="All"
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
	echo "[INFO]: This script will add and remove packages, may break things.";
	read -p "[INFO]: Would you like to continue? (Y/n): " promptResponse
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
echo "[INFO]: Removing common pre-installed packages..."
for (( c=0; c<${#autoPurged[@]}; c++ ))
do
	apt-get remove -y "${autoPurged[$c]}"
done
apt autoremove -y
echo "[INFO]: Updating current source/repo listings..."
apt-get update
echo "[INFO]: Installing my base apt packages via secret cow powers."
for (( c=0; c<${#autoInstallAPTBase[@]}; c++ ))
do
	apt-get install -y "${autoInstallAPTBase[$c]}"
done
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
echo "[INFO]: Installing packages based upon installation type(if needed.)"
case $installType in
	("Base")
		:
		;;
	("All")
		for (( c=0; c<${#autoInstallAPTWork[@]}; c++ ))
		do
			apt-get install -y "${autoInstallAPTWork[$c]}"
		done
		for (( c=0; c<${#autoInstallDEBWork[@]}; c++ ))
		do
			:
		done
		for (( c=0; c<${#autoInstallAPTGame[@]}; c++ ))
		do
			apt-get install -y "${autoInstallAPTGame[$c]}"
		done
		;;
	("Work")
		for (( c=0; c<${#autoInstallAPTWork[@]}; c++ ))
		do
			apt-get install -y "${autoInstallAPTWork[$c]}"
		done
		;;
	("Game")
		for (( c=0; c<${#autoInstallAPTGame[@]}; c++ ))
		do
			apt-get install -y "${autoInstallAPTGame[$c]}"
		done
		;;
esac
echo "[INFO]: Upgrading System."
apt full-upgrade -y && apt dist-upgrade -y && apt-get update
echo "[INFO]: Script has completed."