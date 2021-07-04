#!/bin/bash
echo -e "\u001b[32;1m ghpm - GitHub Project Manager \u001b[0m"
echo

projectdir=$1

if [ -z "$projectdir" ] || [[ "." == "$projectdir"  ]]
then
        projectdir=$PWD
fi

cd "$projectdir" || exit

function get_username
{
    if  [ -z "$username" ]
    then
        echo -e " \u001b[37;1m\u001b[4m Enter GitHub Username:\u001b[0m"
        echo -en "\u001b[32;1m ==> \u001b[0m"
        read -r username
    fi
}

function clone_repos
{
    get_username
    echo -e "\u001b[7m Cloning repos of $username@github \u001b[0m"
    curl -s https://api.github.com/users/"$username"/repos?per_page=100 |jq -r ".[].html_url" | xargs -L1 git clone
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

    cd "$projectdir" || return
done

echo -e "\n\033[32m Complete! \033[0m\n"
}

while true
do

echo -e " \u001b[37;1m\u001b[4m Select an option:\u001b[0m"

echo -e "  \u001b[34;1m (1) Clone repos \u001b[0m"
echo -e "  \u001b[34;1m (2) Pull changes \u001b[0m"
echo -e "  \u001b[34;1m (3) Push changes \u001b[0m"
echo -e "  \u001b[34;1m (4) Set SSH remote \u001b[0m"

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
    update=pull
    update_repos
    echo
    read -r
    ;;

"3")
    update=push
    update_repos
    echo
    read -r
    ;;

"4")
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
