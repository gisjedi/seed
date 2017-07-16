#!/usr/bin/env bash

## Usage: ./generate-release.sh 1.0.0

# Ensure script directory is CWD
cd "${0%/*}"

VERSION=$1
tput setaf 2
echo "Building release $VERSION"
tput sgr0

if [[ $(git rev-parse --abbrev-ref HEAD) != "master" ]]; then
    tput setaf 1
    echo "Current branch is not master!"
    tput sgr0
    git rev-parse --abbrev-ref HEAD
    exit 1
fi

git diff-index --quiet HEAD
if [[ $? != 0 ]]; then
    tput setaf 1
    echo "Current index is not clean!"
    tput sgr0
    git diff-index HEAD
fi

tput setaf 2
echo -e "\nDetach the head"
tput sgr0
git checkout --detach

tput setaf 2
echo -e "\nChange the revision on the release, inject manifests and add version history"
tput sgr0
./set-version.sh $VERSION
./spec/examples/inject-manifests.sh
echo $VERSION >> .versions

tput setaf 2
echo -e "\nCommit the change"
tput sgr0
git commit -a -m "Update version values for release $VERSION"

tput setaf 2
echo -e "\nTag the release"
tput sgr0
git tag -a -m "Seed release $VERSION" $VERSION

tput setaf 2
echo -e "\nPush the changes"
tput sgr0
git push --tags

tput setaf 2
echo -e "\nCheckout back to master"
tput sgr0
git checkout master

tput setaf 2
echo -e "\nAdd $VERSION to version history"
tput sgr0
echo $VERSION >> .versions

tput setaf 2
echo -e "\nCommit the change"
tput sgr0
git commit -a -m "Add $VERSION to version history"

tput setaf 2
echo -e "\nPush the changes"
tput sgr0
git push

tput setaf 2
echo -e "\nDon't forget to update the release notes: https://github.com/ngageoint/seed/releases/edit/$VERSION"
tput sgr0