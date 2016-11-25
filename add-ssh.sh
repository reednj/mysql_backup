#!/bin/sh

#
# This script adds the ssh public key of the current host to the
# remote host given in the first argument
#

REMOTE=$1
LOCAL=`hostname`
PUBLIC_KEY=id_rsa.pub
REMOTE_KEY=$LOCAL.$PUBLIC_KEY

if [ -z "$REMOTE" ]; then
        echo "adds the current hosts ssh key to the remote"
        echo "usage: $0 <remote_host>"
        exit
fi

cd ~/.ssh
scp $PUBLIC_KEY $REMOTE:~/$REMOTE_KEY
ssh $REMOTE "cat $REMOTE_KEY >> ./.ssh/authorized_keys;rm -f $REMOTE_KEY"
