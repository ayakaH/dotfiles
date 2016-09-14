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
    ls $HOME/.gnupg||echo "no .gnupg dir"&&return 1
    ls $HOME/_repo/*xz||echo "no package to sign"&&return 1
    cd $HOME/_repo;for i in *.xz;do gpg --detach-sign $i;done&&
    kill -9 $(pidof gpg-agent)&&
    rm -rf ~/.gnupg
    cp ~/_repo/* ~/repo/;mv ~/_repo/* ~/archive/&&
    echo '_repo';ls ~/_repo
    echo 'repo';ls ~/repo
    ls ~/.gnupg
    ps aux|grep gpg-agent
    echo "DONE!"
}

while getopts "l:r" opt; do
    case $opt in
        l)
            echo "doing local thing."
            local_func
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
