#!/bin/bash
#TODO Add other known SUID lol vulns
declare -a VULNS=(
	"aa-exec" "ab" "agetty" "alpine" "ar" "arj" "arp" "as" "ascii-xfr" "ash" "aspell" "atobm" "awk"
	"base32" "base64" "basenc" "basez" "bash" "bc" "bridge" "busctl" "busybox" "bzip2"
	"cabal" "capsh" "cat" "chmod" "choom" "chown" "chroot" "clamscan" "cmp" "column" "comm" "cp" "cpio" "cpulimit" "csh" "csplit" "csvtool" "cupsfilter" "curl" "cut"
	"dash" "date" "dd"
	"ed" "efax" "elvish" "emacs" "env" "eqn" "espeak" "expand" "expect"
	"file" "find" "fish" "flock" "fmt" "fold"
	"gawk" "gcore" "gdb" "genie" "genisoimage" "gimp" "grep" "gtester" "gzip"
	"hd" "head" "hexdump" "highlight" "hping3"
	"iconv" "install" "ionice" "ip" "ispell"
	"jjs" "join" "jq" "jrunscript" "julia"
	"ksh" "ksshell" "kubectl"
	"ld.so" "less" "links" "logsave" "look" "lua"
	"make" "mawk" "minicom" "more" "mosquitto" "msgattrib" "msgcat" "msgconv" "msgfilter" "msgmerge" "msguniq" "multitime" "mv"
	"nasm" "nawk" "ncftp" "nft" "nice" "nl" "nm" "nmap" "node" "nohup" "ntpdate"
	"od" "openssl" "openvpn"
	"pandoc" "paste" "perf" "perl" "pexec" "pg" "php" "pidstart" "pr" "ptx" "python"
	"rc" "readelf" "restic" "rev" "rlwrap" "rsync" "rtorrent" "run-parts" "rview" "rvim"
	"sash" "scanmem" "sed" "setarch" "setfacl" "setlock" "shuf" "soelim" "softlimit" "sort" "sqlite3" "ss" "ssh-agent" "ssh-keygen" "ssh-keyscan" "sshpass" "start-stop-daemon" "stdbuf" "strace" "strings" "sysctl" "systemctl"
	"tac" "tail" "taskset" "tbl" "tclsh" "tee" "terraform" "tftp" "tic" "time" "timeout" "troff"
	"ul" "unexpand" "uniq" "unshare" "unsquashfs" "unzip" "update-alternatives" "uudecode" "uuencode"
	"vagrant" "varnishncsa" "view" "vigr" "vim" "vimdiff" "vipw" "w3m" "watch" "wc" "wget" "whiptail"
	"xargs" "xdotool" "xmodmap" "xmore" "xxd" "xz"
	"yash"
	"zsh" "zsoelim"
)

# Search for SUID and SGID
#ALL=$(find "/" -perm /6000 -type f 2>/dev/null | sort --unique)
# Search for SUID
ALL=$(find "/" -perm /4000 -type f 2>/dev/null | sort --unique)
#echo "$ALL"

# Get unique filenames
declare -a BASES=()
while IFS= read -r line || [[ -n $line ]]; do
	#echo "${line##*/}"
	[[ " ${BASES[@]} " =~ " ${line##*/} " ]] || BASES+=("${line##*/}");
done < <(printf '%s' "$ALL")

# Resort BASES just in case
IFS=$'\n' sorted=($(sort <<<"${BASES[*]}"))
unset IFS
#echo "${BASES[@]}"

declare -a FOUND=()
for v in "${VULNS[@]}"; do
	[[ " ${BASES[@]} " =~ " ${v} " ]] && FOUND+=("$v")
done
#echo "${FOUND[@]}"

if [[ -z "${FOUND[@]}" ]]; then
	echo "No results found."
	exit 1
else
	echo "Found known vulnerabilit(y/ies):"
	while IFS= read -r line || [[ -n $line ]]; do
		[[ " ${FOUND[@]} " =~ " ${line##*/} " ]] && echo "$line"
	done < <(printf '%s' "$ALL")
fi
