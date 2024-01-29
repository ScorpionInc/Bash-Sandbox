#!/bin/bash

# Global Variables
hashcmds=(cksum md5sum sha1sum sha224sum sha256sum sha384sum sha512sum b2sum)
hashflags=(ck md5 sha1 sha224 sha256 sha384 sha512 b2)
hashmarks=("Chksum: " "MD5   : " "SHA1  : " "SHA224: " "SHA256: " "SHA384: " "SHA512: " "B2    : ")
DEFAULT_PARAMETERS=""
runhashcmds=("${hashcmds[@]}")
hashflagsareset=false
lastflagindex=0

# Functions
get_index() {
	#Pass name of array as $1 value as $2 case sensitivity as $3.
	#Returns 0-based index in array of name $1 where value is $2 on success.
	#Returns empty string on error.
	local -n my_array=$1 # use -n for a reference to the array
	for i in "${!my_array[@]}"; do
		if [[ ${my_array[i]} = $2 ]]; then
			printf '%s\n' "$i"
			return
		fi
	done
	return 1
}
#testarray=("hello" "world" "test" "array");
#testindex=$(get_index testarray test)
#echo "Test Index: $testindex"
validate_hashcmds(){
	#echo "[DEBUG]: Validating hashcmds..."
	for hc in "${!hashcmds[@]}"
	do
		#echo "[DEBUG]: Validating next command: ${hashcmds[hc]}"
		hashcmdfound=false
		for c in $(compgen -c | sort --unique)
		do
			if [[ "$c" == "${hashcmds[hc]}" ]]
			then
				hashcmdfound=true
				#echo "[DEBUG]: ${hashcmds[hc]} valid available command."
			fi
		done
		if [[ "$hashcmdfound" == "true" ]]
		then
			continue
		fi
		#echo "[DEBUG]: Command is not built in. Test for file..."
		if [ -f "${hashcmds[hc]}" ] && [ -x "${hashcmds[hc]}" ]
		then
			#echo "[DEBUG]: ${hashcmds[hc]} is a file and executable."
			:
		else
			echo "[WARN]: ${hashcmds[hc]} is invalid."
			#Remove invalid entry
			#hashcmds=( "${hashcmds[@]/${hashcmds[hc]}}" )
			unset 'hashcmds[hc]'
			unset 'hashflags[hc]'
		fi
	done
	#echo "[DEBUG]: hashcmds have been validated."
	#for hc in "${!hashcmds[@]}"
	#do
	#	echo -n "[DEBUG]: Validated command: ${hashflags[hc]} => "
	#	echo "${hashcmds[hc]}"
	#done
}
validate_hashcmds
generate_default_parameters(){
	#TODO
	#Requires Bash v4+
	#Returns generated default parameters string on success
	#Returns empty string on error.
	local rsv=""
	for hf in "${!hashflags[@]}"
	do
		rsv+="-${hashflags[hf]} "
	done
	if [[ "$rsv" == "" ]]
	then
		:
	else
		printf '%s\n' "${rsv::-1}";
	fi
	return 0;
}
DEFAULT_PARAMETERS="$(generate_default_parameters)"
print_usage(){
	echo "Simple Bash Hashing Script by: ~ScorpionInc"
	echo "hash.sh [--help|-?] - Prints this usage and exits."
	echo "hash.sh - Hashes all files recursively with all installed hashes from cwd."
	echo "hash.sh (filename.ext [...]) - Runs all installed hashes on target file(s)/dir(s)."
	echo "hash.sh [-ck] [-md5] [-sha(1|224|256|384|512)] [-b2] [filename.ext [...]] - Uses specific hashes on all or specific file(s)/dir(s)."
}

# Handle Defaults
if [[ "$#" == "0" ]]
then
	#echo "[DEBUG]: Using defaults"
	"$0" $DEFAULT_PARAMETERS
	exit
fi

# Process Parameters
for i in $( seq 1 1 $# )
do
	#echo -n "[DEBUG]: Parameter[$i]: "
	#echo "${!i}"
	flagwasfound=false
	for hf in "${!hashflags[@]}"
	do
		regex="^-${hashflags[hf]}$"
		if $(echo "${!i}" | grep -qi "$regex")
		then
			#echo "[DEBUG]: Flag ${!i} matches regex '$regex'!"
			if [[ "$hashflagsareset" == "false" ]]
			then
				#First time a hash flag is set
				hashflagsareset=true
				runhashcmds=()
			fi
			runhashcmds+=("${hashcmds[hf]}")
			flagwasfound=true
		fi
	done
	if [[ "$flagwasfound" == "true" ]]
	then
		lastflagindex=$i
		continue
	fi
	if $(echo "${!i}" | grep -qi '^--help$')
	then
		print_usage
		exit
	elif [[ "${!i}" == "-?" ]]
	then
		print_usage
		exit
	elif [ -f "${!i}" ]
	then
		break
	elif [ -d "${!i}" ]
	then
		break
	else
		echo "[ERROR]: Unknown Parameter: '${!i}'."
		print_usage
		exit
	fi
done

# Parameters have been processed
# If we reached here runhashcmds should be set correctly and no usage need be printed.
#echo "[DEBUG]: Last flag was at index of: $lastflagindex"
for rhc in "${runhashcmds[@]}"
do
	#echo "[DEBUG]: Using Command: $rhc"
	rhci=$(get_index hashcmds "$rhc")
	#echo "[DEBUG]: This running hash command's base index: $rhci"
	if [[ $lastflagindex -eq $# ]]
	then
		#echo "[DEBUG]: All files in cwd."
		for f in $(find . -type f)
		do
			if [[ "${#runhashcmds[@]}" == "1" ]]
			then
				:
			else
				echo -n "${hashmarks[rhci]}"
			fi
			#echo "[DEBUG]: Hashing File: $f"
			$rhc $f
		done
	else
		#echo "[DEBUG]: Files/Folders are specifed after flag index."
		for pfi in $(seq $(($lastflagindex + 1)) 1 $#)
		do
			#echo "[DEBUG]: Attempting hashing of File/Folder: ${!pfi}"
			if [[ -f "${!pfi}" ]]
			then
				#Target specified is a file.
				if [[ "${#runhashcmds[@]}" == "1" ]]
				then
					:
				else
					echo -n "${hashmarks[rhci]}"
				fi
				$rhc "${!pfi}"
			elif [ -d "${!pfi}" ]
			then
				#Target specified is a directory.
				for f in $(find "${!pfi}" -type f)
				do
					#echo "[DEBUG]: Hash target dir->file: $f"
					if [[ "${#runhashcmds[@]}" == "1" ]]
					then
						:
					else
						echo -n "${hashmarks[rhci]}"
					fi
					$rhc "$f"
				done
			else
				#Target is invalid
				echo "[ERROR]: Invalid parameter: '${!pfi}'."
				break
			fi
		done
	fi
done
