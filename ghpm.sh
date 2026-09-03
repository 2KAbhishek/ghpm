#!/usr/bin/env bash
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

function clone_public_repos {
    get_username
    [[ -z "$username" ]] && return

    echo -e "\u001b[7m\n Cloning public repos of $username@github \u001b[0m"
    if command -v gh &>/dev/null; then
        gh repo list "$username" --limit 1000 --json url -q ".[].url" | xargs -L1 git clone
    else
        local public_repos
        public_repos=$(curl -s "https://api.github.com/users/$username" | jq -r '.public_repos // 0' 2>/dev/null)
        if [[ "$public_repos" =~ ^[0-9]+$ ]] && [ "$public_repos" -gt 0 ]; then
            local page_count=$(( (public_repos + 99) / 100 ))
            for ((i = 1; i <= page_count; i++)); do
                curl -s "https://api.github.com/users/$username/repos?page=$i&per_page=100" |
                    jq -r '.[].html_url // empty' 2>/dev/null | xargs -L1 git clone
            done
        fi
    fi
}

function success {
    echo -e "\n\033[32m Complete! \033[0m\n"
}

function to_ssh_url {
    local url="$1"
    if [[ "$url" =~ ^git@ ]]; then
        [[ "$url" != *.git ]] && url="${url}.git"
        echo "$url"
        return
    fi
    url="${url%.git}"
    url="${url#*://}"
    url="${url#*@}"
    local host="${url%%/*}"
    local path="${url#*/}"
    echo "git@${host}:${path}.git"
}

function repo_operation {
    for git_dir in */.git; do
        [[ -d "$git_dir" ]] || continue
        local repo="${git_dir%/.git}"

        (
            cd "$repo" || exit 1
            case "$1" in
            "ssh-remote")
                echo -e "\u001b[7m\n Setting ssh remote for $repo \u001b[0m"
                local current_url
                current_url=$(git remote get-url origin 2>/dev/null || true)
                if [ -n "$current_url" ]; then
                    local ssh_url
                    ssh_url=$(to_ssh_url "$current_url")
                    git remote set-url origin "$ssh_url"
                else
                    echo "No origin remote found for $repo"
                fi
                ;;

            "custom")
                echo -e "\u001b[7m\n Running $2 in $repo \u001b[0m"
                eval "$2"
                ;;

            esac
        )
    done
}

while true; do
    echo -e " \u001b[37;1m\u001b[4m Select an option:\u001b[0m"

    echo -e "  \u001b[34;1m (1) Clone own repos (requires GitHub CLI) \u001b[0m"
    echo -e "  \u001b[34;1m (2) Clone public repos of others \u001b[0m"
    echo -e "  \u001b[34;1m (3) Run command in all repos \u001b[0m"
    echo -e "  \u001b[34;1m (4) Set SSH remote \u001b[0m"
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
        repo_operation "ssh-remote"
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
