#!/bin/bash
echo -e "\u001b[32;1m ghpm - GitHub Project Manager \u001b[0m"
echo

project_dir=$1

if [ -z "$project_dir" ] || [[ "." == "$project_dir" ]] || [ ! -d "$project_dir" ]; then
    project_dir=$PWD
fi

cd "$project_dir" || exit

function clone_self_repos {
    gh repo list --json sshUrl -q ".[].sshUrl" -L 500 | xargs -L1 gh repo clone
}

function get_username {
    if [ -z "$username" ]; then
        echo -e " \u001b[37;1m\u001b[4m Enter GitHub Username:\u001b[0m"
        echo -en "\u001b[32;1m ==> \u001b[0m"
        read -r username
    fi
}

function get_page_count {
    page_count=0
    public_repos=$(curl -s "https://api.github.com/users/$username" | jq -r ."public_repos")

    echo -e "\u001b[32;1m\u001b[4m\nPublic Repository Count: $public_repos\u001b[0m"
    ((page_count = public_repos / 100 + 1))
}

function clone_public_repos {
    get_username
    get_page_count
    echo -e "\u001b[7m\n Cloning public repos of $username@github \u001b[0m"
    for ((i = 1; i <= page_count; i++)); do
        curl -s "https://api.github.com/users/$username/repos?page=$i&per_page=100" |
            jq -r ".[].html_url" | grep -i "$username" | xargs -L1 git clone
    done
}

function success {
    echo -e "\n\033[32m Complete! \033[0m\n"
}

function repo_operation {
    for i in $(find . -maxdepth 2 -name ".git" | cut -c 3-); do
        cd "$i" || return
        cd ..
        repo=$(pwd | awk -F/ '{print $NF}')

        case "$1" in
        "ssh-remote")
            echo -e "\u001b[7m\n Setting ssh remote for $repo \u001b[0m"
            get_username
            git remote set-url origin git@github.com:"${username}/${repo}.git"
            ;;

        "custom")
            echo -e "\u001b[7m\n Running $2 in $repo \u001b[0m"
            $2
            ;;

        esac

        cd "$project_dir" || return
    done
}

while true; do
    echo -e " \u001b[37;1m\u001b[4m Select an option:\u001b[0m"

    echo -e "  \u001b[34;1m (1) Clone own repos \u001b[0m"
    echo -e "  \u001b[34;1m (2) Clone public repos of others \u001b[0m"
    echo -e "  \u001b[34;1m (3) Pull changes \u001b[0m"
    echo -e "  \u001b[34;1m (4) Push changes \u001b[0m"
    echo -e "  \u001b[34;1m (5) Set SSH remote \u001b[0m"
    echo -e "  \u001b[31;1m (0) Exit \u001b[0m"

    echo -en "\u001b[32;1m ==> \u001b[0m"

    read -r option
    case $option in

    "1")
        clone_self_repos
        success
        read -r
        ;;

    "2")
        clone_public_repos
        success
        read -r
        ;;

    "3")
        echo -e " \u001b[37;1m\u001b[4m Enter command to run (e.g: git pull) \u001b[0m"
        echo -en "\u001b[32;1m ==> \u001b[0m"
        read -r custom_command
        repo_operation "custom" "$custom_command"
        success
        read -r
        ;;

    "4")
        update=push
        update_repos
        echo
        read -r
        ;;

    "5")
        update_repos
        echo
        success
        read -r
        ;;

    "0")
        echo -e "\u001b[32;1m Bye! \u001b[0m"
        exit 0
        ;;

    *)
        echo -e "\u001b[31;1m Invalid option entered! \u001b[0m"
        exit 1
        ;;

    esac
done
