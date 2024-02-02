#!/bin/bash
sudo apt-get install steamcmd coreutils nano
echo
echo Checking for game server updates...
echo
steamcmd +login anonymous +app_update 2394010 +quit
echo
echo Testing initialization settings...
echo
if [ -f ~/.local/share/Steam/steamapps/common/PalServer/DefaultPalWorldSettings.ini ]; then
	echo "Default Configuration File Exists."
	if test ! -f ~/.local/share/Steam/steamapps/common/PalServer/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini; then
		cp ~/.local/share/Steam/steamapps/common/PalServer/DefaultPalWorldSettings.ini ~/.local/share/Steam/steamapps/common/PalServer/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini
		nano "~/.local/share/Steam/steamapps/common/PalServer/Pal/Saved/Config/LinuxServer/PalWorldSettings.ini"
	else
		echo "PalWorldSettings are already defined."
	fi
else
	echo "Default Configuration File not found."
fi
launchtime="$(date +%s)"
echo
echo Launching game server at apx. $launchtime...
echo
nohup /bin/bash -c '~/.local/share/Steam/steamapps/common/PalServer/PalServer.sh -ServerName="ScorpionInc PalWorld Server" -port=8211 -players=12 -log -nosteam -useperfthreads -NoAsyncLoadingThread -UseMultithreadForDS EpicApp=PalServer' </dev/null >server.$launchtime.log 2>&1 &
disown
echo
echo Game Server should now be running detached from current session.
echo
