# Bash-Sandbox
Sandbox for Bash Scripting

# Install .bash_profile Script.
WGet Method (Run As User):
> [[ -e ~/.bash_profile ]] && cp ~/.bash_profile ~/.bash_profile.backup; wget -O ~/.bash_profile https://github.com/ScorpionInc/Bash-Sandbox/raw/main/.bash_profile && . ~/.bash_profile

Curl Method (Run As User):
> [[ -e ~/.bash_profile ]] && cp ~/.bash_profile ~/.bash_profile.backup; curl -o ~/.bash_profile https://github.com/ScorpionInc/Bash-Sandbox/raw/main/.bash_profile && . ~/.bash_profile
