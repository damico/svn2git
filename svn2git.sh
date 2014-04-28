#!/bin/bash

REPO=svn-repo-name
SVNUSER=username
SVNPASSWD=******
SVNHOST=192.168.1.1
SVNPATH=svn
SVNPROTOCOL=https
SVNURL=$SVNPROTOCOL://$SVNUSER:$SVNPASSPWD@$SVNHOST/$SVNPATH
GITROOT=/opt/git-repo
SVNTMP=/tmp/svn

echo "============================="
echo "Importing: "$REPO
echo "============================="


mkdir $SVNTMP
cd $SVNTMP
svn co $SVNURL/$REPO/
cd $REPO
svn log -q | awk -F '|' '/^r/ {sub("^ ", "", $2); sub(" $", "", $2); print $2" = "$2" <"$2">"}' | sort -u > authors-transform.txt
mkdir /tmp/svn/$REPO-svn-git
cd $SVNTMP/$REPO-svn-git
git svn init $SVNURL/$REPO/ --no-metadata
git config svn.authorsfile $SVNTMP/$REPO/authors-transform.txt 
git svn fetch
git init --bare $GITROOT/$REPO.git
cd $GITROOT/$REPO.git
git symbolic-ref HEAD refs/heads/trunk
cd $SVNTMP/$REPO-svn-git
git remote add bare /opt/git-repo/$REPO.git
git config remote.bare.push 'refs/remotes/*:refs/heads/*'
git push bare
cd /
rm -rf $SVNTMP
