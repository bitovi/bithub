#!/bin/sh

eval "$(ssh-agent -s)"

chmod 600 ./.travis/deploy-key.pem
ssh-add ./.travis/deploy-key.pem

git fetch --unshallow || true
git fetch origin "+refs/heads/*:refs/remotes/origin/*"

git remote add deploy ssh://bithub@45.79.143.148/home/bithub/server.git
# Do not change this line. Travis has the ability push back to the repository
# https://docs.travis-ci.com/user/github-oauth-scopes/
git push -f deploy staging:staging
