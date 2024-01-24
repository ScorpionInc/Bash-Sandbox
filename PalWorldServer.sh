#!/bin/bash
@echo off
sudo apt-get install steamcmd nohup disown
echo
echo Checking for game server updates...
echo
steamcmd +login anonymous +app_update 2394010 +quit
echo
echo Testing initialization settings...
echo
if test -f "./"; then
	echo "Default Configuration File Exists."
fi
echo
echo Launching game server...
echo
nohup /bin/bash -c './steamapps/common/PalServer/PalServer -ServerName="ScorpionInc PalWorld Server" -port=8211 -players=12 -log -nosteam -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS EpicApp=PalServer' </dev/null >server.log 2>&1 &
disown
echo
echo Game Server should now be running detached from current session.
echo