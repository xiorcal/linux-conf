#!/bin/bash
#####################
###### VARS #########
#####################
export no_proxy="localhost, 127.0.0.1, .be12.local, .bi12.local, .bi3.local, .be3.local"
export CONF_HOME=/home/mlacroix/dev/misc/linux-conf

#####################
###### CONF #########
#####################
export EDITOR=vim
export HISTTIMEFORMAT="%d/%m/%y %T "
#####################
##### STUFF #########
#####################
function openTunnel() {
	local tunnelName=$1
	local localPort=$2
	local remoteHost=$3
	local remotePort=$4

	if ! nc -nz 127.0.0.1 "$localPort"; then
		echo "Establishing a tunnel to $remoteHost:$remotePort ($tunnelName) on the local port $localPort..."
		ssh -NfL "$localPort":"$remoteHost":"$remotePort" "$(whoami)"@"${TUNNEL_HOST}"
	fi
}

echoerr() { printf "%s\\n" "$*" >&2; }

function git_rebase_master() {
	git pull --rebase origin master
}

function git_oops() {
	git add "$@"
	git commit --amend -C HEAD
}
alias git_double_oops='git reset --soft HEAD@{1}'

function git_force_reset() {
	git fetch origin
	git reset --hard origin/master
	git clean -fdx
}

function plantuml() {
	filename=$1
	java -jar ~/apps/plantuml.jar "$filename"
	filename="${filename%.*}"
	xdg-open "${filename}.png"
}

function epoch() {
	if [ "$#" -eq 0 ]; then
		date +%s
	else
		date -d @"$1"
	fi
}

function atom() {
	if [ "$#" -eq 0 ]; then
		/usr/bin/atom ~/dev
	else
		/usr/bin/atom -a "$@"
	fi
}

function ud() {
	if [ "$#" -lt 2 ]; then
		nb=0
	else
		nb=$2
	fi
	CMD="import urbandictionary as ud;d=ud.define('$1')[$nb];print d.word+':'+d.definition"
	python -c "$CMD"
}

function upgrade_atom() {
	rm -f /tmp/atom.deb
	curl -L https://atom.io/download/deb >/tmp/atom.deb
	sudo dpkg --install /tmp/atom.deb
}
function upgrade_vsc() {
	rm -f /tmp/vsc.deb
	curl -L https://vscode-update.azurewebsites.net/latest/linux-deb-x64/stable >/tmp/vsc.deb
	sudo dpkg --install /tmp/vsc.deb
}

function urlencode() {
	echo -n "$1" | perl -MURI::Escape -ne 'print uri_escape($_)'
}

function google() {
	query=$(urlencode "$*")
	xdg-open "https://google.fr/search?q=$query"
}

function ebook() {
	if [ -z "$EBOOK_DIR" ]; then
		echoerr 'EBOOK_DIR is not set'
		exit 78
	fi
	tmp_dir=$(mktemp -d)
	backup_start_dir=$(pwd)

	# rename
	for f in "$@"; do
		cp "${f}" "${tmp_dir}"
	done
	cd "${tmp_dir}" || exit
	# retrait id
	rename 's/^[^A-Za-z]+//' ./*
	rename 's/ *\[eBook\] *//' ./*
	rename 'y/A-Z/a-z/' ./*
	mv "${tmp_dir}"/* "${EBOOK_DIR}"
	rm "${tmp_dir}" -rf
	cd "${backup_start_dir}" || exit
	for f in "$@"; do
		rm "${f}"
	done
}

function renderMD() {
	temp_file=$(mktemp)
	pandoc --from markdown_github --to html5 --output "${temp_file}" --standalone "$1"
	sensible-browser "${temp_file}"
	rm "${temp_file}"
}

function avrocount() {
	for var in "$@"; do
		echo "$var : $(avro-tools tojson "$var" 2>/dev/null | wc -l)"
	done
}

function roger() {
	cat <<endOfFuck
        __   
       /  \\      
       |  |
       |  |
     __|  |__
    /  |  |  \\__ 
  __|  |  |  |  |
 /  /        |  |
 |              |
 \\              |
  \\             /
   \\___________/

endOfFuck
}

function script_dir() {
	# shellcheck disable=SC2016
	echo '"$(dirname "$(readlink -f "$0")")"'
}

bash_match() {
	regex="$1"
	var="$2"
	if [[ "$var" =~ $regex ]]; then
		echo "matches"
		return 0
	else
		echo "doesn't match!"
		return 1
	fi
}

function asciicast2gif() {
	if [ "$#" -lt 1 ]; then
		echo "specify at least input file (json record)"
		return
	elif [ "$#" -lt 2 ]; then
		output="$1.gif"
	else
		output="$2"
	fi
	docker run --rm -v "$PWD:/data" asciinema/asciicast2gif "$1" "$output"

}

export HISTTIMEFORMAT="[%F %T] "
export HISTFILE=~/.zsh_history
export HISTSIZE=999999999
export SAVEHIST=$HISTSIZE
export PROMPT_COMMAND="history -a; $PROMPT_COMMAND"

#####################
###### ALIAS ########
#####################
alias ll='ls -alhF'
alias la='ls -A'
alias l='ls -CF'
alias eject=''
alias burp='fortune | cowsay'
alias vi='vim'
alias w='thunar . &'
alias b='cd -'
alias cls='clear'
alias lll='ll'
alias editprofile='code $CONF_HOME/bash_stuff.sh ~/dev/misc/scripts/pj.sh'
alias sourceprofile="source ~/.zshrc"
alias cd..='cd ..'
alias mdPreview='renderMD'
alias emptygz='gzip < /dev/null > empty.gz'
alias meteoB='curl -H "Accept-Language: fr" wttr.in/brest,+france'
alias meteoR='curl -H "Accept-Language: fr" wttr.in/rennes,+france'
alias initPy='cp $CHEATSHEETS_DIR/python/empty.py'
alias ps='ps -e -f'
alias clearSocle='rm ~/.ivy2/cache/fr.pagesjaunes.audience.socle.* -rf'
alias rmSocle='clearSocle'
alias history='fc -i -l 1'
