#!/bin/bash
echo
echo Installing tools...
echo
sudo apt-get install docker docker-compose wget
echo
echo Setting up user/system docker compose cli-plugin
echo
# User
if [ ! -f $HOME/.docker/cli-plugins/docker-compose ]; then
	echo docker-compose seems to be missing for the current user. Attempting to add...
	wget -c --output-file=$HOME/.docker/cli-plugins https://github.com/docker/compose/releases/download/v2.24.3/docker-compose-linux-x86_64
	mv $HOME/.docker/cli-plugins/docker-compose-linux-x86_64 $HOME/.docker/cli-plugins/docker-compose
	chmod 754 $HOME/.docker/cli-plugins/docker-compose
fi
# System (might require sudo?)
if [ ! -f /usr/local/lib/docker/cli-plugins/docker-compose ]; then
	echo docker-compose seems to be missing for the system cli-plugin. Attempting to add...
	wget -c --output-file=/usr/local/lib/docker/cli-plugins https://github.com/docker/compose/releases/download/v2.24.3/docker-compose-linux-x86_64
	mv /usr/local/lib/docker/cli-plugins/docker-compose-linux-x86_64 /usr/local/lib/docker/cli-plugins/docker-compose
	chmod 754 /usr/local/lib/docker/cli-plugins/docker-compose
fi
echo
echo Starting Lavalink server via docker...
echo
sudo nohup docker compose up</dev/null >lava.$(date +%s).log 2>&1 &
disown
echo
echo Server should be running now with log: ./lava.$(date +%s).log
echo
