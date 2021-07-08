#!/bin/bash
echo -e "\u001b[32;1m ghpm - GitHub Project Manager \u001b[0m"
echo

project_dir=$1
public_repos=0
page_count=0

if [ -z "$project_dir" ] || [[ "." == "$project_dir"  ]] || [ ! -d $project_dir ]
then
        project_dir=$PWD
fi

cd "$project_dir" || exit

function get_username
{
    if  [ -z "$username" ]
    then
        echo -e " \u001b[37;1m\u001b[4m Enter GitHub Username:\u001b[0m"
        echo -en "\u001b[32;1m ==> \u001b[0m"
        read -r username
    fi
}

function get_token
{
    if  [ -z "$token" ]
    then
        echo -e " \u001b[37;1m\u001b[4m Enter GitHub Token:\u001b[0m"
        echo -en "\u001b[32;1m ==> \u001b[0m"
        read -r token
    fi
}

function get_public_repo_count
{
        public_repos=$(curl -s "https://api.github.com/users/$username" | jq -r ."public_repos")
        echo -e "\u001b[32;1m\u001b[4m\nPublic Repository Count: $public_repos\n\u001b[0m"
        (( page_count=public_repos/100 + 1 ))

}

function clone_repos
{
    get_username
    get_token
    echo -e "\u001b[7m Cloning repos of $username@github \u001b[0m"
    echo $clone_cmd
    curl -su "$username":"$token" https://api.github.com/user/repos?per_page=200 \
        | jq -r ".[].ssh_url" | xargs -L1 git clone
    echo -e "\n\033[32m Complete! \033[0m\n"
}

#curl -s "https://api.github.com/users/$username/repos?page=2&per_page=100"|\
# jq -r ".[].ssh_url" | xargs -L1 git clone # When repo count is more than 100

function clone_public_repos
{
    get_username
    echo -e "\u001b[7m Cloning public repos of $username@github \u001b[0m"
    curl -s https://api.github.com/users/"$username"/repos?per_page=200 \
        | jq -r ".[].html_url" | xargs -L1 git clone
    echo -e "\n\033[32m Complete! \033[0m\n"
}

function update_repos
{
echo -e "\n\033[1m  Updating all repositories. \033[0m\n"

for i in $(find . -maxdepth 2 -name ".git" | cut -c 3-); do
    cd "$i" || return;
    cd ..;

    repo=$(pwd | awk -F/ '{print $NF}')

    if [ "$update" == "pull" ] || [ "$update" == "push" ]
    then
        git "$update";
    else
        get_username
        git remote set-url origin git@github.com:"${username}/${repo}.git"
    fi
    echo -e "\033[33m $repo \033[0m";
    echo ;

    cd "$project_dir" || return
done

echo -e "\n\033[32m Complete! \033[0m\n"
}

while true
do

echo -e " \u001b[37;1m\u001b[4m Select an option:\u001b[0m"

echo -e "  \u001b[34;1m (1) Clone repos \u001b[0m"
echo -e "  \u001b[34;1m (2) Clone public repos \u001b[0m"
echo -e "  \u001b[34;1m (3) Pull changes \u001b[0m"
echo -e "  \u001b[34;1m (4) Push changes \u001b[0m"
echo -e "  \u001b[34;1m (5) Set SSH remote \u001b[0m"

echo -e "  \u001b[31;1m (0) Exit \u001b[0m"

echo -en "\u001b[32;1m ==> \u001b[0m"

read -r option

case $option in

"1")
    clone_repos
    echo
    read -r
    ;;

"2")
    clone_public_repos
    echo
    read -r
    ;;

"3")
    update=pull
    update_repos
    echo
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
