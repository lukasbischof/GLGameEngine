#!/bin/bash

cd /Volumes/Macintosh\ HD/Users/Lukas/Desktop/Development/iOS\ \&\ Mac\ OS\ X/iOS/Open\ GL\ ES/GLGameEngine/

git status

printf "\n\nCurrent Branches: \n"
git branch

echo -n "Which one do you want to commit?: "
read branch

git push origin $branch
