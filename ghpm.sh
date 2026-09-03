#!/usr/bin/env bash

# Color definitions
C_RESET=$'\033[0m'
C_BOLD=$'\033[1m'
C_UNDERLINE=$'\033[4m'
C_GREEN=$'\033[32;1m'
C_BLUE=$'\033[34;1m'
C_RED=$'\033[31;1m'
C_WHITE=$'\033[37;1m'
C_REV=$'\033[7m'

echo -e "${C_GREEN} ghpm - GitHub Project Manager ${C_RESET}\n"

project_dir=$1

if [ -z "$project_dir" ] || [[ "." == "$project_dir" ]] || [ ! -d "$project_dir" ]; then
    project_dir=$PWD
fi

cd "$project_dir" || exit

function check_gh {
    if ! command -v gh &>/dev/null; then
        echo -e "${C_RED}Error: GitHub CLI (gh) is not installed.${C_RESET}"
        return 1
    fi
}

function clone_self_repos {
    check_gh || return 1
    echo -e "${C_REV}\n Cloning own repositories via GitHub CLI... ${C_RESET}"
    gh repo list --json sshUrl -q ".[].sshUrl" -L 500 | xargs -L1 gh repo clone
}

function get_username {
    if [ -z "$username" ]; then
        echo -e " ${C_WHITE}${C_UNDERLINE}Enter GitHub Username:${C_RESET}"
        echo -en "${C_GREEN} ==> ${C_RESET}"
        read -r username
    fi
}

function clone_public_repos {
    get_username
    [[ -z "$username" ]] && return

    echo -e "${C_REV}\n Cloning public repos of $username@github ${C_RESET}"
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
    echo -e "\n${C_GREEN} Complete! ${C_RESET}\n"
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
                echo -e "${C_REV}\n Setting ssh remote for $repo ${C_RESET}"
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
                echo -e "${C_REV}\n Running $2 in $repo ${C_RESET}"
                eval "$2"
                ;;

            esac
        )
    done
}

while true; do
    echo -e " ${C_WHITE}${C_UNDERLINE}Select an option:${C_RESET}"

    echo -e "  ${C_BLUE} (1) Clone own repos (requires GitHub CLI) ${C_RESET}"
    echo -e "  ${C_BLUE} (2) Clone public repos of others ${C_RESET}"
    echo -e "  ${C_BLUE} (3) Run command in all repos ${C_RESET}"
    echo -e "  ${C_BLUE} (4) Set SSH remote ${C_RESET}"
    echo -e "  ${C_RED} (0) Exit ${C_RESET}"

    echo -en "${C_GREEN} ==> ${C_RESET}"

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
        echo -e " ${C_WHITE}${C_UNDERLINE}Enter command to run (e.g: git pull)${C_RESET}"
        echo -en "${C_GREEN} ==> ${C_RESET}"
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
        echo -e "${C_GREEN} Bye! ${C_RESET}"
        exit 0
        ;;

    *)
        echo -e "${C_RED} Invalid option entered! ${C_RESET}"
        exit 1
        ;;

    esac
done
