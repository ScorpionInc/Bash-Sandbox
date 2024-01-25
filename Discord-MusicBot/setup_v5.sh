#!/bin/bash
echo
echo Installing tools...
echo
sudo apt-get install npm yarn nodejs
echo
echo Assuming Lavalink is being handled by Admin...
#https://github.com/lavalink-devs/Lavalink/
echo
echo Grabbing/Cloning latest source from master branch repo
echo
git clone -b v5 https://github.com/SudhanPlayz/Discord-MusicBot.git Discord-MusicBot-v5
cd ./Discord-MusicBot-v5
nano ./config.js
touch ./package.json
chmod 766 ./package.json
npm install
npm run deploy
nohup npm run start</dev/null >DMB5.$(date +%s).log 2>&1 &
disown
echo
echo Server should now be running with log: ./Discord-MusicBot-v5/DMB5.$($date +%s).log...
echo
