#!/bin/bash

# Umask (rwx) owner/group/others 1-Turns Off
# TODO I'd like to have a minimum mask and bitwise and it with the current mask.
#  in that case its already more strict and I would want to keep that.
umask 037

# Fetch aliases for Bash profile.
if [ -n "$BASH_VERSION" ]; then
	if [ ! -f "${HOME}/.bash_aliases" ]; then
		if which wget >/dev/null ; then
			wget -O "${HOME}/.bash_aliases" https://github.com/ScorpionInc/Bash-Sandbox/raw/main/.bash_aliases
		elif which curl >/dev/null ; then
			curl -o "${HOME}/.bash_aliases" https://github.com/ScorpionInc/Bash-Sandbox/raw/main/.bash_aliases
		fi
	fi
fi

# Loads function(s) script(s) from path similar to alias scripts above.
#if [ -f "${HOME}/.bash_functions" ]; then
#	source "${HOME}/.bash_functions"
#fi

# Tests if a path is defined within the $PATH variable
has_search_path(){
	local $search_path="$1"
	p=$(echo $PATH | tr ":" "\n")
	for $q in $p
	do
		if [[ "$q" == "$search_path" ]]; then
			return true
		fi
	done
	return false
}
# Updates scripts from my(maybe other peoples eventually?) github repo(s).
# TODO
update_scripts(){
	echo update scripts was called.
}

# Pings the default gateway to test basic network availability.
ping_default_gateway(){
	return $(ping -q -w 1 -c 1 `ip r | grep default | cut -d ' ' -f 3` > /dev/null);
}
# Updates system files / programs & libraries using first available package manager.
dist_upgrade(){
	if [ $(dpkg-query -W -f='${Status}' 'apt' 2>/dev/null | grep -c "ok installed") -eq 1 ]; then
		# Debian / Ubuntu
		# Test if we are on a network
		if ! ping_default_gateway; then
			# If there is not a current network response,
			# Try enabling the wifi if network-manager is installed.
			# For some reason it is off by default on my current installation.
			if [ $(dpkg-query -W -f='${Status}' 'network-manager' 2>/dev/null | grep -c "ok installed") -eq 1 ]; then
				sudo nmcli radio wifi on
				sleep 3
			else
				return 0;
			fi
		fi
		sudo apt-get update --fix-missing && sudo apt dist-upgrade --fix-missing || return 0;
	elif [ $(dpkg-query -W -f='${Status}' 'yum' 2>/dev/null | grep -c "ok installed") -eq 1 ]; then
		# Fedora
		sudo yum update || return 0;
	elif [ $(dpkg-query -W -f='${Status}' 'pacman' 2>/dev/null | grep -c "ok installed") -eq 1 ]; then
		# Arch
		sudo pacman -Syu || return 0;
	elif [ $(dpkg-query -W -f='${Status}' 'emerge' 2>/dev/null | grep -c "ok installed") -eq 1 ]; then
		# Gentoo / Portage
		emerge -uDNav world || return 0;
	else
		echo "[ERROR]: No package manager found." # Debugging
		return 0;
	fi
	# Update Snap installation(s)
	if [ $(dpkg-query -W -f='${Status}' 'snap' 2>/dev/null | grep -c "ok installed") -eq 1 ]; then
		sudo snap refresh;
	fi
	return 1;
}

# Attempts to detect the init system installed on the current box by looking at /sbin/init.
# Modified from code: https://unix.stackexchange.com/a/325832
find_init_type(){
	if ! test -f /sbin/init; then
		echo "NONE";
		return 1;
	fi
	cat /sbin/init | awk 'match($0, /(upstart|systemd|sysvinit)/) { print toupper(substr($0, RSTART, RLENGTH));exit; }' 2> /dev/null
	return 0;
}

# Lists Services based upon init system
ls_services(){
	case $(find_init_type) in
	"UPSTART")
		sudo initctl list;
		return 0;
	;;
	"SYSTEMD")
		#ls /lib/systemd/system/*.service /etc/systemd/system/*.service
		sudo systemctl --all list-unit-files --type=service
		return 0;
	;;
	"SYSVINIT")
		#ls /etc/init.d/
		#ls /etc/rc*.d/
		sudo service --status-all;
		return 0;
	;;
	*)
		return 1;
	;;
	esac
}

# Returns current Fully Qualified domain name(hopefully).
get_fqdn(){
	# Getting the FQDN methods seem to be inconsistent.
	# Reference code: https://serverfault.com/a/367682
	h=$(hostname -s 2> /dev/null)
	if [ $? -ne 0 ]; then
		h=$(hostname 2> /dev/null)
		if [ $? -ne 0 ]; then
			echo -n "${1:-<Unknown>}"
			return 2;
		fi
	fi
	if command -v host &> /dev/null; then
		fqn=$(host -TtA ${h} | grep "has address" | awk '{print $1}');
		if [[ "${fqn}" == "" ]]; then
			fqn="${h}";
		fi
		echo -n "${fqn}"
		return 0;
	fi
	echo -n '\\\\'"${h}"
	return 1;
}

# ANSI Code functions/definitions

# Changes the window title with ANSI Codes
set_title(){
	echo -ne "\e]2;$@\a\e]1;$@\a";
}

# Following code was sourced from: https://github.com/vaniacer/bash_color/blob/master/color

#--------------------------------------------------------------------+
#Color picker, usage: printf $BLD$CUR$RED$BBLU'Hello World!'$DEF	 |
#-------------------------+--------------------------------+---------+
#	   Text color		|	   Background color		 |		 |
#-----------+-------------+--------------+-----------------+		 |
# Base color|Lighter shade| Base color   | Lighter shade   |		 |
#-----------+-------------+--------------+-----------------+		 |
BLK='\e[30m'; blk='\e[90m'; BBLK='\e[40m'; bblk='\e[100m' #| Black   |
RED='\e[31m'; red='\e[91m'; BRED='\e[41m'; bred='\e[101m' #| Red	 |
GRN='\e[32m'; grn='\e[92m'; BGRN='\e[42m'; bgrn='\e[102m' #| Green   |
YLW='\e[33m'; ylw='\e[93m'; BYLW='\e[43m'; bylw='\e[103m' #| Yellow  |
BLU='\e[34m'; blu='\e[94m'; BBLU='\e[44m'; bblu='\e[104m' #| Blue	|
MGN='\e[35m'; mgn='\e[95m'; BMGN='\e[45m'; bmgn='\e[105m' #| Magenta |
CYN='\e[36m'; cyn='\e[96m'; BCYN='\e[46m'; bcyn='\e[106m' #| Cyan	|
WHT='\e[37m'; wht='\e[97m'; BWHT='\e[47m'; bwht='\e[107m' #| White   |
#-------------------------{ Effects }----------------------+---------+
DEF='\e[0m'   #Default color and effects							 |
BLD='\e[1m'   #Bold\brighter										 |
DIM='\e[2m'   #Dim\darker											|
CUR='\e[3m'   #Italic font										   |
UND='\e[4m'   #Underline											 |
INV='\e[7m'   #Inverted											  |
COF='\e[?25l' #Cursor Off											|
CON='\e[?25h' #Cursor On											 |
#------------------------{ Functions }-------------------------------+
# Text positioning, usage: XY 10 10 'Hello World!'				   |
XY(){ printf "\e[$2;${1}H$3"; }									 #|
# Print line, usage: line - 10 | line -= 20 | line 'Hello World!' 20 |
line(){ printf -v _L %$2s; printf -- "${_L// /$1}"; }			   #|
# Create sequence like {0..(X-1)}, usage: que 10					 |
que(){ printf -v _N %$1s; _N=(${_N// / 1}); printf "${!_N[*]}"; }   #|
#--------------------------------------------------------------------+
# loops are better on large scales like 20000+ but fail on 1000 or less
# line(){ for ((i=0; i<$2; i++)); { printf -- '%s' "$1"; }
# que(){ printf 0; for ((i=1; i<$1; i++)); { printf -- " %s" $i; }

# END Code Sourced from: https://github.com/vaniacer/bash_color/blob/master/color

# Modified from source: https://stackoverflow.com/a/43832956
# Used with sed to escape possible delimiter(s) character(s)
function escape_forward_slashes(){
	if [ -z "$1" ]
	then
		echo -e "[ERROR]: escape_forward_slashes() failed due to lack of parameter(s)." # Debugging
		return 1
	fi
	local safe_str=$(echo "$1" | sed -e "s~/~\\\/~g")
	echo $safe_str
	return 0
}
#echo $(escape_forward_slashes "/Test") # !Debugging

function escape_backward_slashes(){
	if [ -z "$1" ]
	then
		echo -e "[ERROR]: escape_backward_slashes() failed due to lack of parameters." #!Debugging
		return 1
	fi
	local safe_str=$(echo "$1" | sed -e 's/[\]/\\\\/g')
	echo "$safe_str"
	return 0
}
#echo $(escape_backward_slashes "\\Test") # !Debugging

# Modified from source: https://gist.github.com/TrinityCoder/911059c83e5f7a351b785921cf7ecdaa#file-center_text_in_bash-md
function print_centered {
	[[ $# == 0 ]] && return 1
	declare -i TERM_COLS="$(tput cols)"
	ANSI_Filtered_String=$(echo "$1" | sed -r "s/\\\e\[([0-9]{1,3}(;[0-9]{1,3})*)?[mGK]//g")
	declare -i str_len="${#ANSI_Filtered_String}"
	[[ $str_len -ge $TERM_COLS ]] && {
		printf "${1}";
		return 0;
	}
	declare -i filler_len="$(( (TERM_COLS - str_len) / 2 ))"
	[[ $# -ge 2 ]] && ch="${2:0:1}" || ch=" "
	filler=""
	for (( i = 0; i < filler_len; i++ )); do
		filler="${filler}${ch}"
	done
	printf "${filler}${1}${filler}"
	[[ $(( (TERM_COLS - str_len) % 2 )) -ne 0 ]] && printf "${ch}"
	printf "\n"
	return 0;
}
# End of modified source

# Text-Art Sourced/Modified from: https://emojicombos.com/scorpion-ascii-art
BANNER_ICON="${ylw}
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⣴⣶⣶⣶⡦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣧⣝⠛⠛⠋⢾⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣠⡙⠿⡟⠋${DEF}${RED}⢀⣀⣀${DEF}${ylw}⣌⣽⣯⡷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⠁${DEF}${red}⠐${DEF}${RED}⠉⠈${DEF}${ylw}⢻⣷⡻⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣩⣶⣧⡀⠀⠀⢀⣸⣿⠿⢛⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣯⣷⣶⣦⣠⡾⢡⣾⢿⡿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢀⣠⡿⠻⣆⣘⢸⣿⣻⣾⣿⡷⣛⠵⢟⣱⡾⣻⣷⣿⢶⣤⣴⣤⠀⠀⠀
⠀⠀⣸⠟⣡⣤⣤⣬⣿⣣⣅⣿⡿⣷⣿⣿⣿⣞⠋⣐⣻⠏⣜⠛⢿⣿⣽⣷⣄⠀
⠀⢀⡇⢐⣿⢁⡴⠽⣷⣾⡿⠻⣷⣹⡛⠿⠿⣭⣜⡛⠃⠀⠹⠤⠀⠘⣿⣿⣿⣷
⠐⠉⠀⠈⣿⢸⣇⢰⡾⠿⠿⠛⠛⠋⡥⢾⠃${DEF}${red}⣍⠉⠿⠀⠀⠀⠀${DEF}${YLW}⣰⣿⠿⠟⢛⡋${DEF}${ylw}
⠀⠀⠀⠀⣺⢘⡏⢸⠟⠀⢐⣭⢻⠿⣿⠏⠁${DEF}${red}⠈⠀⠀⠀⠀⠀⠀${DEF}${YLW}⠿⠋⠀⢀⣾⠇${DEF}${ylw}
⠀⠀⠀⠈⠁⠀⣹⠹⣆⢠⣿⣿⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${DEF}${YLW}⠠⠟⠁${DEF}${ylw}⠀
⠀⠀⠀⠀⠀⠘⠁⠀⡾⠸⣿⣟⣿⣷⣶⣶⣤${DEF}${YLW}⣀⣀⣀⣀⣀${DEF}${ylw}⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⢸⣿⣿⣿⣿⡿${DEF}${YLW}⠟⠿⠛⠟⠉⠃${DEF}${ylw}⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠛⠉${DEF}${YLW}⠺⠷⢦⠶⠷⠊${DEF}${ylw}⠀⠀⠀⠀⠀⠀⠀⠀
${DEF}"
#BANNER_ICON=("${ylw}\n" "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⣴⣶⣶⣶⡦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣧⣝⠛⠛⠋⢾⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "⠀⠀⠀⠀⠀⠀⠀⠀⣠⡙⠿⡟⠋${DEF}${RED}⢀⣀⣀${DEF}${ylw}⣌⣽⣯⡷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⠁${DEF}${red}⠐${DEF}${RED}⠉⠈${DEF}${ylw}⢻⣷⡻⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "⠀⠀⠀⠀⠀⠀⠀⠀⣩⣶⣧⡀⠀⠀⢀⣸⣿⠿⢛⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀" "⠀⠀⠀⠀⠀⠀⠀⠀⣿⣯⣷⣶⣦⣠⡾⢡⣾⢿⡿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀" "⠀⠀⠀⢀⣠⡿⠻⣆⣘⢸⣿⣻⣾⣿⡷⣛⠵⢟⣱⡾⣻⣷⣿⢶⣤⣴⣤⠀⠀⠀" "⠀⠀⣸⠟⣡⣤⣤⣬⣿⣣⣅⣿⡿⣷⣿⣿⣿⣞⠋⣐⣻⠏⣜⠛⢿⣿⣽⣷⣄⠀" "⠀⢀⡇⢐⣿⢁⡴⠽⣷⣾⡿⠻⣷⣹⡛⠿⠿⣭⣜⡛⠃⠀⠹⠤⠀⠘⣿⣿⣿⣷" "⠐⠉⠀⠈⣿⢸⣇⢰⡾⠿⠿⠛⠛⠋⡥⢾⠃⣍⠉⠿⠀⠀⠀⠀${DEF}${YLW}⣰⣿⠿⠟⢛⡋${DEF}${ylw}" "⠀⠀⠀⠀⣺⢘⡏⢸⠟⠀⢐⣭⢻⠿⣿⠏⠁⠈⠀⠀⠀⠀⠀⠀${DEF}${YLW}⠿⠋⠀⢀⣾⠇${DEF}${ylw}" "⠀⠀⠀⠈⠁⠀⣹⠹⣆⢠⣿⣿⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${DEF}${YLW}⠠⠟⠁${DEF}${ylw}⠀" "⠀⠀⠀⠀⠀⠘⠁⠀⡾⠸⣿⣟⣿⣷⣶⣶⣤${DEF}${YLW}⣀⣀⣀⣀⣀${DEF}${ylw}⠀⠀⠀⠀⠀⠀⠀⠀" "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⢸⣿⣿⣿⣿⡿${DEF}${YLW}⠟⠿⠛⠟⠉⠃${DEF}${ylw}⠀⠀⠀⠀⠀⠀⠀" "⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠛⠉${DEF}${YLW}⠺⠷⢦⠶⠷⠊${DEF}${ylw}⠀⠀⠀⠀⠀⠀⠀⠀" "${DEF}")
# Prints Banner with some basic information on shell open.
echo_profile_banner(){
	# TODO Fix print_centered function for multi-line inputs.
	#for icon_line in ${BANNER_ICON[@]}; do
		#print_centered "${icon_line}";
	#done
	print_centered "$BANNER_ICON";
	print_centered ""
	print_centered "${wht}Welcome back, ${BLD}$(id -u -n):$(id -g -n)${DEF}${wht}.${DEF}"
	print_centered "${wht}$(get_fqdn)${DEF} ${wht}${UND}$(date)${DEF}"
	print_centered ""
}

# Hashing Stuffs (WIP)
#openssl list -digest-algorithms | grep -Ev "(=>|:)" | grep -Eo "[a-zA-Z][a-zA-Z0-9 /,-]+" | grep -Ev "(default|NULL)" | sed 's/, /\n/g' | sort -fu
#openssl list -digest-algorithms | grep -Eo "[a-zA-Z][a-zA-Z0-9 /,-]+" | grep -Ev "(default|NULL|=>|:)" | sed 's/, /\n/g' | sort -fu
#for digest in ${openssl_digests[@]}; do echo $digest; done;
#for i in ${!openssl_digests[@]}; do echo "$i is ${openssl_digests[$i]}"; done;
openssl_digests=("blake2b512" "blake2s256" "md4" "md5" "mdc2" "rmd160" "sha1" "sha224" "sha256" "sha384" "sha512" "sha3-224" "sha3-256" "sha3-384" "sha3-512" "sha512-224" "sha512-256" "shake128" "shake256" "sm3")
# /usr/bin/{$i}sum
sum_digests=("b2" "ck" "md5" "sha1" "sha224" "sha256" "sha384" "sha512")
# blake2b512 CRC32(?) md5

clear
echo_profile_banner

# Source .bashrc from home for .bash_profile
. ~/.bashrc
