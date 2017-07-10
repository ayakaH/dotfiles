#!/bin/bash

function local_func() {
    rsync -v -r ~/.gnupg barch:~
    while [[ ! $reply == "y" ]];do
        echo "rsync done, go server sign them now(y/n)";
        read reply;
    done;
    echo "DONE!"
}

function remote_func() {
    (
    cd $HOME/_repo;for i in *.xz;do gpg --detach-sign $i;done&&
    kill -9 $(pidof gpg-agent)&&
    rm -rf ~/.gnupg&&
    mkdir -p ~/archive
    cp ~/_repo/* ~/repo/;mv ~/_repo/* ~/archive/&&
    echo '_repo';ls ~/_repo
    echo 'repo';ls ~/repo
    ls ~/.gnupg
    ps aux|grep gpg-agent|grep yk|awk '{print $2}'|xargs kill -9
    ps aux|grep pinentry-curses|grep yk|awk '{print $2}'|xargs kill -9
    echo "DONE!"
    )
}

while getopts ":lr" opt; do
    case $opt in
        l)
            echo "doing local thing."
            local_func
            ssh -t barch zsh
            ;;
        r)
            echo "well, doing remote now."
            remote_func
            ;;
        *)
            echo "what did you say?"
            ;;
    esac
done
