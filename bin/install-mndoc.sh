#!/usr/bin/env bash

function installBinary() {
    BASEURL=${1%/}
    APP=$2
    #echo ${BASEURL}
    RELEASE=`curl -isS "$BASEURL/$APP/releases/latest/" | grep -i '^location:'`
    VERSION=`echo "$RELEASE" | sed -E 's/.+v([.0-9]+).+/\1/'`
    URL="$BASEURL/$APP/releases/download/v${VERSION}/$APP-${VERSION}.bin"
    BINDIR="$HOME/.local/bin"
    mkdir -p "$BINDIR"
    curl -fsSL "$URL" --output "$BINDIR/$APP"
    chmod 755 "$BINDIR/$APP"
    echo "testing $APP version"
    "$BINDIR/$APP" --version
    echo "Looks good. Installed $APP!"
    if [[ ":$PATH:" != *":$BINDIR:"* ]]; then
        echo "$BINDIR is not in your PATH"
        echo "add the following line to your .bashrc or .zshrc file"
        echo "echo \$PATH | grep -q /.local/bin || export PATH=~/.local/bin:\$PATH"
        yes_or_no "Do you like to add this PATH adaptation to your .bashrc file?" && add_local_bin_path
        
    else 
        echo "$BINDIR is already in your PATH"
    fi 
}

function add_local_bin_path {
    echo "echo \$PATH | grep -q /.local/bin || export PATH=~/.local/bin:\$PATH" >> "$HOME/.bashrc"
    source "$HOME/.bashrc"
    echo "Path was updated in .bashrc"
}
function yes_or_no {
   while true; do
       read -r -p "$* [y/n]: " yn
        case $yn in
            [Yy]*) return 0  ;;  
            [Nn]*) echo "Aborted" ; return  1 ;;
        esac
    done
}
installBinary https://github.com/mittelmark mndoc
