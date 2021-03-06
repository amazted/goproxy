#!/bin/bash

GOROOT=/go
GOPATH=/home/phuslu/GOPATH
PATH=$PATH:$GOROOT/bin:$GOPATH/bin

cd /home/phuslu/goproxy
git clean -df
git reset --hard

git branch -D bak
git checkout -b bak
git branch -D master
git fetch origin
git checkout master

REV=`git rev-list HEAD | wc -l | xargs`
NOTE=`git log --oneline | head -1`
REMOTE=`git remote -v | head -1 | awk '{print $2}'`

cd /home/phuslu/goproxy/goproxy
mkdir -p dist

PACKAGE_GOOS=windows PACKAGE_GOARCH=386 make && mv build/dist/goproxy* dist/ && make clean
PACKAGE_GOOS=windows PACKAGE_GOARCH=amd64 make && mv build/dist/goproxy* dist/ && make clean
PACKAGE_GOOS=linux PACKAGE_GOARCH=amd64 make && mv build/dist/goproxy* dist/ && make clean
PACKAGE_GOOS=linux PACKAGE_GOARCH=386 make && mv build/dist/goproxy* dist/ && make clean
PACKAGE_GOOS=linux PACKAGE_GOARCH=arm make && mv build/dist/goproxy* dist/ && make clean
PACKAGE_GOOS=darwin PACKAGE_GOARCH=amd64 make && mv build/dist/goproxy* dist/ && make clean

export GITHUB_TOKEN=`cat ~/GITHUB_TOKEN`
export GITHUB_USER=$(basename `dirname $REMOTE`)
export GITHUB_REPO=$(basename $REMOTE)

github-release delete --tag goproxy
github-release release --tag goproxy --name "goproxy r${REV}" --description "r${REV}: ${NOTE}"
for f in `ls dist`; do
    github-release -v upload --user phuslu --repo goproxy --tag goproxy --name $f --file dist/$f
done
