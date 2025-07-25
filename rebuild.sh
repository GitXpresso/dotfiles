
id | grep "codeany" 1>&2 >/dev/null
if [ $? -eq 0 ]; then
   echo "Username "codeany" is one your system running..."
   sleep 0.5
   clear
else
   echo "Username "codeany" is not on your system not running this script"
   sleep 0.5
   exit 1
   clear
fi
if [ -d /etc/apt ]; then
if [ -f $HOME/.bash_history ]; then
   echo ".bash_history exists."
else 
   echo ".bash_history does not exist."
   history -w
   echo "done adding ~/.bash_history"
   sleep 0.5 
   clear
fi
   grep "sudo apt update" ~/.bash_history 2>&1 >/dev/null

   if [ $? -eq 0 ]; then  
       echo "already updated your system"
       sleep 0.5
       clear
   else 
       echo "you did not update your system, updating..."
       sudo apt update
       sleep 0.5
       clear
   fi
   if [ -f /usr/bin/neofetch ]; then
       echo "neofetch is already installed."
       sleep 0.5
       clear
   else
       echo "neofetch is not installed, installing..."
       sudo apt install neofetch -y
       sleep 0.5
       clear
   fi
     if [ -f /usr/bin/pv ]; then
       echo "pv is already installed."
       sleep 0.5
       clear
   else
       echo "pv is not installed, installing..."
       sudo apt install pv -y
       sleep 0.5
       clear
   fi
   if [ -f /usr/bin/openbox ]; then
       echo "openbox is already installed."
       sleep 0.5
       clear
   else
       echo "openbox is not installed, installing..."
       sudo apt install openbox -y
       sleep 0.5
       clear
   fi
   if [ -d /usr/share/novnc ]; then
       echo "novnc is already installed."
       sleep 0.5
       clear
   else
       echo "novnc is not installed, installing..."
       sudo apt install novnc -y
       sleep 0.5
       clear
   fi
   if [ -f /usr/bin/websockify ]; then
       echo "websockify is already installed."
       sleep 0.5
       clear
   else
       echo "websockify is not installed, installing..."
       sudo apt install websockify -y
       sleep 0.5
       clear
   fi
   if [ -d /etc/tigervnc ]; then
       echo "tigervnc-standalone-server is already installed."
       sleep 0.5
       clear
   else
       echo "tigervnc-standalone-server is not installed, installing..."
       sudo apt install tigervnc-standalone-server -y
       sleep 0.5
       clear
   fi
   if [ -f /usr/bin/wget ]; then
       echo "wget is already installed."
       sleep 0.5
       clear
   else
       echo "wget is not installed, installing..."
       sudo apt install -y wget
       sleep 0.5
       clear
   fi
   if [ -f /usr/bin/extrepo ]; then
       echo "extrepo is already installed."
       sleep 0.5
       clear
   else
       echo "extrepo is not installed, installing..."
       sudo apt install -y extrepo
       sleep 0.5
       clear
   fi
   if [ -f /usr/bin/batcat ]; then
       echo "bat is already installed."
       sleep 0.5
       clear
   else
       echo "bat is not installed, installing..."
       sudo apt install -y bat
       sleep 0.5
       clear
   fi
   if [ -f /usr/bin/tilix ]; then
       echo "tilix is already installed."
       sleep 0.5
       clear
   else
       echo "tilix is not installed, installing..."
       sudo apt install -y tilix
       sleep 0.5
       clear
   fi
   if [ -f /usr/bin/librewolf ]; then
       echo "librewolf is already installed."
       sleep 0.5
       clear
   else
       echo "installing librewolf"
       sudo extrepo enable librewolf
       sudo apt update
       sleep 0.5
       clear
       echo "installing librewolf"
       sudo apt install -y librewolf
       sleep 0.5
       clear 
       echo "done installing librewolf"
       sleep 0.5
       clear
   fi
   if [ -f /usr/bin/ccrypt ]; then
       echo "ccrypt is already installed."
       sleep 0.5
       clear
   else
       echo "installing ccrypt"
       sudo apt install -y ccrypt
       sleep 0.5
       clear 
   fi
else     
echo "your not on a debian based system"
exit 1
fi

mkdir -p ~/bashrc
cat << 'EOF' >~/bashrc/.bashrc
# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
neofetch
EOF

cat << 'EOF' >~/bashrc.sh
#!/bin/bash
cp ~/bashrc/.bashrc ~/.bashrc
EOF
echo "adding executable permissions.."
sudo chmod +x ~/bashrc.sh
clear
echo "moving ~/bashrc.sh to /etc/profile.d/..."
sudo mv ~/bashrc.sh /etc/profile.d/
clear
clear
echo "done Moving"
cat << 'EOF' >~/librewolf.sh
tigervncserver -xstartup /usr/bin/openbox -geometry 1366x768 -localhost no :0
websockify -D --web=/usr/share/novnc/  --cert=~/linux-novnc/novnc.pem 6080 localhost:5900
librewolf --display=:0
EOF
echo "adding executable permissions.."
sudo chmod +x ~/librewolf.sh
clear
echo "moving ~/librewolf.sh to /etc/profile.d/..."
sudo mv ~/librewolf.sh /etc/profile.d/
clear
redo(){
if [ -d ~/.librewolf/ ]; then
 read -p "there already files in ~/.librewolf, do you want to override? (y/n/yes/no): " yesorno1
if [ "$yesorno1" = "y" ] || [ "$yesorno1" = "yes" ]; then
 echo "checkng if pv is installed..."
   if [ ! -f /usr/bin/pv ]; then
      sudo apt install pv -y
   else
      echo "pv is installed."
   fi
   clear
   echo "downloading librewolf.tar.cpt..."
 if [ ! -f ~/.librewolf3.tar.cpt ]; then
      wget --show-progress https://github.com/GitXpresso/dotfiles/releases/download/Files/librewolf3.tar.cpt
      sleep 0.5
      clear
   else
      echo "file already there."
      sleep 0.5
      clear
   fi
      ccrypt -d librewolf3.tar.cpt
   if [ -f ./librewolf3.tar.cpt ]; then
      clear
      echo "incorrect password, try again."
      ccrypt -d librewolf3.tar.cpt
   else
      pv ./librewolf.tar | tar -xf    
      cp -r ./librewolf/.librewolf ~/.librewolf
   fi
elif [ $yesorno1 == no | $yesorno1 == n ]; then 
     echo "not overriding ~/.librewolf." 
     exit 1
else 
    echo "invalid input, try again."
    redo
fi
else 
    echo "~/.librewolf does not exist continuing with the script."
    exit 1
    redo
fi
} 
if [ -d ~/.librewolf/ ]; then
read -p "there already files in ~/.librewolf, do you want to override? (y/n/yes/no): " yesorno1
if [ "$yesorno1" = "y" ] || [ "$yesorno1" = "yes" ]; then
   echo "downloading librewolf3.tar.cpt..."
 if [ ! -f ./librewolf.tar.cpt ]; then
      wget --show-progress https://github.com/GitXpresso/dotfiles/releases/download/Files/librewolf3.tar.cpt
      sleep 0.5
      clear
   else
      echo "file already there."
      sleep 0.5
      clear
   fi 
   sudo ccrypt -d librewolf3.tar.cpt
   if [ -f ./librewolf3.tar.cpt ]; then
      clear
      echo "incorrect password, try again."
      sudo ccrypt -d librewolf3.tar.cpt
   else
      pv "./librewolf3.tar" | tar -xf-   
      cd ./home/codeany/.librewolf/436rkz4f.default-default
      sudo rm -r {settings,storage}
      sudo cp -r * ~/.librewolf/*.default-default/ 
      rm librewolf3*
   fi
elif [ $yesorno1 == no ] || [ $yesorno1 == n ]; then 
     echo "not overriding ~/.librewolf." 
     exit 1
else 
    echo "invalid input, try again."
    redo
fi
  else 
    echo "~/.librewolf does not exist continuing with the script."
    bash /etc/profile.d/librewolf.sh
    vncserver -kill :1
    redo
fi
echo "finished!"