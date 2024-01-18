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

# Changes the window title with ANSI Codes
set_title(){
	echo -ne "\e]2;$@\a\e]1;$@\a";
}

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
	# Getting the FQDN methods seem to be inconsistent. TODO Fix errors for msys compatibility(broken).
	# Reference code: https://serverfault.com/a/367682
	fqn=$(host -TtA $(hostname -s) | grep "has address" | awk '{print $1}' 2> /dev/null);
	if [[ "${fqn}" == "" ]]; then fqn=$(hostname -s) 2> /dev/null; fi;
	return $fqn
}
# Text-Art Sourced/Modified from: https://emojicombos.com/scorpion-ascii-art
BANNER_ICON="
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⣴⣶⣶⣶⡦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⢠⣿⣧⣝⠛⠛⠋⢾⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣠⡙⠿⡟⠋⢀⣀⣀⣌⣽⣯⡷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣿⣿⠁⠐⠉⠈⢻⣷⡻⣿⠇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣩⣶⣧⡀⠀⠀⢀⣸⣿⠿⢛⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⣿⣯⣷⣶⣦⣠⡾⢡⣾⢿⡿⣿⣦⡀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⢀⣠⡿⠻⣆⣘⢸⣿⣻⣾⣿⡷⣛⠵⢟⣱⡾⣻⣷⣿⢶⣤⣴⣤⠀⠀⠀
⠀⠀⣸⠟⣡⣤⣤⣬⣿⣣⣅⣿⡿⣷⣿⣿⣿⣞⠋⣐⣻⠏⣜⠛⢿⣿⣽⣷⣄⠀
⠀⢀⡇⢐⣿⢁⡴⠽⣷⣾⡿⠻⣷⣹⡛⠿⠿⣭⣜⡛⠃⠀⠹⠤⠀⠘⣿⣿⣿⣷
⠐⠉⠀⠈⣿⢸⣇⢰⡾⠿⠿⠛⠛⠋⡥⢾⠃⣍⠉⠿⠀⠀⠀⠀⣰⣿⠿⠟⢛⡋
⠀⠀⠀⠀⣺⢘⡏⢸⠟⠀⢐⣭⢻⠿⣿⠏⠁⠈⠀⠀⠀⠀⠀⠀⠿⠋⠀⢀⣾⠇
⠀⠀⠀⠈⠁⠀⣹⠹⣆⢠⣿⣿⣄⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠟⠁⠀
⠀⠀⠀⠀⠀⠘⠁⠀⡾⠸⣿⣟⣿⣷⣶⣶⣤⣀⣀⣀⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢻⢸⣿⣿⣿⣿⡿⠟⠿⠛⠟⠉⠃⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠙⠛⠛⠉⠺⠷⢦⠶⠷⠊⠀⠀⠀⠀⠀⠀⠀⠀
"
# Prints Banner with some basic information on shell open.
echo_profile_banner(){
	echo "$BANNER_ICON"
	echo "Welcome back, \\\\$(hostname)\\$(id -u -n):$(id -g -n)."
	echo "$(get_fqdn) $(date)"
	echo ""
}

# Hashing Stuffs (WIP)
#openssl list -digest-algorithms | grep -Ev "(=>|:)" | grep -Eo "[a-zA-Z][a-zA-Z0-9 /,-]+" | grep -v "default" | sed 's/, /\n/g' | sort
#for digest in ${openssl_digests[@]}; do echo $digest; done;
#for i in ${!openssl_digests[@]}; do echo "$i is ${openssl_digests[$i]}"; done;
openssl_digests=("blake2b512" "blake2s256" "md4" "md5" "mdc2" "rmd160" "sha1" "sha224" "sha256" "sha3-224" "sha3-256" "sha3-384" "sha3-512" "sha384" "sha512" "sha512-224" "sha512-256" "shake128" "shake256" "sm3")
# /usr/bin/{$i}sum
sum_digests=("b2" "ck" "md5" "sha1" "sha224" "sha256" "sha384" "sha512")

cls
echo_profile_banner

# End of my code.
