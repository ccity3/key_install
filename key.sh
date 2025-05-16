#!/usr/bin/env bash
#=============================================================
# https://github.com/ccity3/key_install
#=============================================================

version=1
red="\033[31m"
green="\033[1;32m"
reset="\033[0m"
info="[${green}info${reset}]"
error="[${red}error${reset}]"
[ "$EUID" -ne 0 ] && sudo_prefix=sudo

usage() {
    echo "
ssh key installer $version

usage:
  bash <(curl -fsSL yourscript.sh) [options...] <arg>

options:
  -w    overwrite mode (clear authorized_keys)
  -g    get public key from github (arg: github username)
  -r    get public key from remote url (arg: url)
  -p    change ssh port (arg: new port number)
  -d    disable ssh password login"
}

[ $# -eq 0 ] && usage && exit 1

check_key_format() {
    [[ "$pub_key" =~ ^ssh-(rsa|ed25519|dss|ecdsa) ]] || {
        echo -e "$error invalid ssh key format."
        exit 1
    }
}

get_github_key() {
    [ -z "$key_id" ] && read -e -p "github username: " key_id
    [ -z "$key_id" ] && echo -e "$error invalid input." && exit 1

    echo -e "$info github username: $key_id"
    echo -e "$info fetching key from github..."
    pub_key=$(curl -fsSL "https://github.com/${key_id}.keys")
    [[ "$pub_key" == "not found" || -z "$pub_key" ]] && {
        echo -e "$error github account not found or no ssh key."
        exit 1
    }
    check_key_format
}

get_remote_key() {
    [ -z "$key_url" ] && read -e -p "remote url: " key_url
    [ -z "$key_url" ] && echo -e "$error invalid input." && exit 1

    echo -e "$info fetching key from url..."
    pub_key=$(curl -fsSL "$key_url")
    check_key_format
}

install_key() {
    [ -z "$pub_key" ] && echo -e "$error ssh key is empty." && exit 1

    mkdir -p "$HOME/.ssh"
    touch "$HOME/.ssh/authorized_keys"

    if [ "$overwrite" == 1 ]; then
        echo -e "$info overwriting authorized_keys..."
        echo "$pub_key" > "$HOME/.ssh/authorized_keys"
    else
        grep -qF "$pub_key" "$HOME/.ssh/authorized_keys" && {
            echo -e "$info ssh key already exists, skipped."
            return
        }
        echo -e "$info adding key to authorized_keys..."
        echo "$pub_key" >> "$HOME/.ssh/authorized_keys"
    fi

    chmod 700 "$HOME/.ssh"
    chmod 600 "$HOME/.ssh/authorized_keys"
    echo -e "$info ssh key installation completed."
}

change_port() {
    echo -e "$info changing ssh port to ${ssh_port} ..."
    if [ "$(uname -o)" == android ]; then
        sed -i "s@^#*port .*@port ${ssh_port}@" "$PREFIX/etc/ssh/sshd_config" && restart_sshd=2 || {
            echo -e "$error failed to change ssh port."
            exit 1
        }
    else
        $sudo_prefix sed -i "s@^#*port .*@port ${ssh_port}@" /etc/ssh/sshd_config && restart_sshd=1 || {
            echo -e "$error failed to change ssh port."
            exit 1
        }
    fi
    echo -e "$info ssh port changed."
}

disable_password() {
    echo -e "$info disabling ssh password login..."
    if [ "$(uname -o)" == android ]; then
        sed -i "s@^#*passwordauthentication .*@passwordauthentication no@" "$PREFIX/etc/ssh/sshd_config" && restart_sshd=2 || {
            echo -e "$error failed to disable password login."
            exit 1
        }
    else
        $sudo_prefix sed -i "s@^#*passwordauthentication .*@passwordauthentication no@" /etc/ssh/sshd_config && restart_sshd=1 || {
            echo -e "$error failed to disable password login."
            exit 1
        }
    fi
    echo -e "$info password login disabled."
}

while getopts "wg:r:p:d" opt; do
    case "$opt" in
    w) overwrite=1 ;;
    g) key_id="$OPTARG"; get_github_key; install_key ;;
    r) key_url="$OPTARG"; get_remote_key; install_key ;;
    p) ssh_port="$OPTARG"; change_port ;;
    d) disable_password ;;
    *) usage; exit 1 ;;
    esac
done

if [ "$restart_sshd" = 1 ]; then
    echo -e "$info restarting sshd service..."
    $sudo_prefix systemctl restart sshd && echo -e "$info sshd restarted."
elif [ "$restart_sshd" = 2 ]; then
    echo -e "$info please restart termux app or sshd manually."
fi
