#!/bin/bash
echo
echo Installing tools...
echo
sudo apt-get install npm yarn nodejs
echo
echo Assuming Lavalink is being handled by Admin...
#https://github.com/lavalink-devs/Lavalink/
echo
echo Grabbing/Cloning `latest` source from master branch repo
echo
git clone https://github.com/SudhanPlayz/Discord-MusicBot.git Discord-MusicBot-v4
cd ./Discord-MusicBot-v4
#nano ./botconfig.js
nano ./config.js
npm install
nohup node ./index.js</dev/null >DMB4.$(date +%s).log 2>&1 &
disown
echo
echo Server should now be running with log: ./Discord-MusicBot-v4/DMB4.$($date +%s).log...
echo
