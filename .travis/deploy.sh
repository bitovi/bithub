#!/bin/sh

eval "$(ssh-agent -s)"

chmod 600 ./.travis/deploy-key.pem
ssh-add ./.travis/deploy-key.pem

git fetch --unshallow || true
git fetch origin "+refs/heads/*:refs/remotes/origin/*"

git remote add deploy ssh://bithub@45.79.201.206/home/bithub/bithub.git
# Do not change this line. Travis has the ability push back to the repository
# https://docs.travis-ci.com/user/github-oauth-scopes/
git push -f deploy develop:master
