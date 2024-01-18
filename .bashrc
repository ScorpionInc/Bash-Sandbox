# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls -F --color=tty'
    alias dir='dir --color=auto --format=vertical'
    alias vdir='vdir --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

#if [ -f ~/.bash_aliases ]; then
#    . ~/.bash_aliases
#fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Start of my code.

# Umask (rwx) owner/group/others 1-Turns Off
# TODO I'd like to have a minimum mask and bitwise and it with the current mask.
#  in that case its already more strict and I would want to keep that.
umask 037

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
update_scripts(){
	echo update scripts was called.
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
			fqn=$(h);
		fi
		echo -n "${fqn}"
		return 0;
	fi
	echo -n "${h}"
	return 1;
}

# ANSI Code functions/definitions

# Changes the window title with ANSI Codes
set_title(){
	echo -ne "\e]2;$@\a\e]1;$@\a";
}

# Following code was sourced from: https://github.com/vaniacer/bash_color/blob/master/color

#--------------------------------------------------------------------+
#Color picker, usage: printf $BLD$CUR$RED$BBLU'Hello World!'$DEF     |
#-------------------------+--------------------------------+---------+
#       Text color        |       Background color         |         |
#-----------+-------------+--------------+-----------------+         |
# Base color|Lighter shade| Base color   | Lighter shade   |         |
#-----------+-------------+--------------+-----------------+         |
BLK='\e[30m'; blk='\e[90m'; BBLK='\e[40m'; bblk='\e[100m' #| Black   |
RED='\e[31m'; red='\e[91m'; BRED='\e[41m'; bred='\e[101m' #| Red     |
GRN='\e[32m'; grn='\e[92m'; BGRN='\e[42m'; bgrn='\e[102m' #| Green   |
YLW='\e[33m'; ylw='\e[93m'; BYLW='\e[43m'; bylw='\e[103m' #| Yellow  |
BLU='\e[34m'; blu='\e[94m'; BBLU='\e[44m'; bblu='\e[104m' #| Blue    |
MGN='\e[35m'; mgn='\e[95m'; BMGN='\e[45m'; bmgn='\e[105m' #| Magenta |
CYN='\e[36m'; cyn='\e[96m'; BCYN='\e[46m'; bcyn='\e[106m' #| Cyan    |
WHT='\e[37m'; wht='\e[97m'; BWHT='\e[47m'; bwht='\e[107m' #| White   |
#-------------------------{ Effects }----------------------+---------+
DEF='\e[0m'   #Default color and effects                             |
BLD='\e[1m'   #Bold\brighter                                         |
DIM='\e[2m'   #Dim\darker                                            |
CUR='\e[3m'   #Italic font                                           |
UND='\e[4m'   #Underline                                             |
INV='\e[7m'   #Inverted                                              |
COF='\e[?25l' #Cursor Off                                            |
CON='\e[?25h' #Cursor On                                             |
#------------------------{ Functions }-------------------------------+
# Text positioning, usage: XY 10 10 'Hello World!'                   |
XY(){ printf "\e[$2;${1}H$3"; }                                     #|
# Print line, usage: line - 10 | line -= 20 | line 'Hello World!' 20 |
line(){ printf -v _L %$2s; printf -- "${_L// /$1}"; }               #|
# Create sequence like {0..(X-1)}, usage: que 10                     |
que(){ printf -v _N %$1s; _N=(${_N// / 1}); printf "${!_N[*]}"; }   #|
#--------------------------------------------------------------------+
# loops are better on large scales like 20000+ but fail on 1000 or less
# line(){ for ((i=0; i<$2; i++)); { printf -- '%s' "$1"; }
# que(){ printf 0; for ((i=1; i<$1; i++)); { printf -- " %s" $i; }

# END Code Sourced from: https://github.com/vaniacer/bash_color/blob/master/color

# Modified from source: https://gist.github.com/TrinityCoder/911059c83e5f7a351b785921cf7ecdaa#file-center_text_in_bash-md
function print_centered {
     [[ $# == 0 ]] && return 1
     declare -i TERM_COLS="$(tput cols)"
     declare -i str_len="${#1}"
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
⠐⠉⠀⠈⣿⢸⣇⢰⡾⠿⠿⠛⠛⠋⡥⢾⠃⣍⠉⠿⠀⠀⠀⠀${DEF}${YLW}⣰⣿⠿⠟⢛⡋${DEF}${ylw}
⠀⠀⠀⠀⣺⢘⡏⢸⠟⠀⢐⣭⢻⠿⣿⠏⠁⠈⠀⠀⠀⠀⠀⠀${DEF}${YLW}⠿⠋⠀⢀⣾⠇${DEF}${ylw}
⠀⠀⠀⠈⠁⠀⣹⠹⣆⢠⣿⣿⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀${DEF}${YLW}⠠⠟⠁${DEF}${ylw}⠀
⠀⠀⠀⠀⠀⠘⠁⠀⡾⠸⣿⣟⣿⣷⣶⣶⣤${DEF}${YLW}⣀⣀⣀⣀⣀${DEF}${ylw}⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⢸⣿⣿⣿⣿⡿${DEF}${YLW}⠟⠿⠛⠟⠉⠃${DEF}${ylw}⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠛⠉${DEF}${YLW}⠺⠷⢦⠶⠷⠊${DEF}${ylw}⠀⠀⠀⠀⠀⠀⠀⠀
${DEF}"
# Prints Banner with some basic information on shell open.
echo_profile_banner(){
	# TODO Fix print_centered function for multi-line inputs.
	print_centered "$BANNER_ICON"
	print_centered "${WHT}Welcome back, \\\\$(hostname)\\$(id -u -n):$(id -g -n)."
	print_centered "$(get_fqdn) $(date)${DEF}"
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
alias cls='clear'

clear
echo_profile_banner

# End of my code.
