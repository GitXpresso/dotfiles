if grep -qi "Debian" /etc/*release && elif grep -qi "Ubuntu" /etc/*release; then
while true; do
read -p "Do you want to install zrok ( an ngrok alternative ) (yes/no/y/n): " yesorno1
sudo apt update 
if [[ "$yesorno1" == "yes" || "$yesorno1" == "y" ]]; then
   echo "Installing zrok..."
if [ -f /usr/bin/zrok ]; then
   echo "zrok is installed."
   exit 1
else
   echo "Zrok is not installed, installing..."
fi
if [ -f /usr/bin/tar ]; then
   echo "tar is installed, not installing."
else
   echo "tar is not installed, installing..."
   clear
   sudo apt install tar -y
   echo "tar is installed, checking if wget is installed..."
fi
   sleep 0.5 
   clear
if [ -f /usr/bin/wget ]; then
   echo "wget is installed"
else
   echo "wget is not installed, installing..."
   sudo apt install -S wget -y
   sleep 0.5
   clear
   echo "wget is installed, installing zrok..."
fi
   sleep 0.5 
   clear
   echo "downloading zrok tarfile..."
   wget https://github.com/openziti/zrok/releases/download/v1.0.4/zrok_1.0.4_linux_amd64.tar.gz -q --show-progress
   sleep 0.5
   clear
   echo "done downloading zrok tar file."
   echo "Extracting tarfile..."
   tar -xvf ./zrok_1.0.4_linux_amd64.tar.gz 
   echo "done extracting, moving zrok to /usr/bin..."
   sudo mv ./zrok /usr/bin
   sleep 0.5
   clear
   echo "zrok is located at $(whereis zrok)"
   sleep 0.5
   clear
   echo "finished, to run zrok do: 'zrok'"
   rm zrok_1.0.4_linux_amd64.tar.gz
fi
elif [[ "$yesorno1" == "no" || "$yesorno1" == "n" ]]; then
  echo "Not installing zrok."
  exit 1
else
  echo "Invalid option, try again..."
  sleep 0.2
  clear
fi
if grep -qi "Fedora" /etc/*release; then
  if rpm -q ncurses; then
    echo "Ncurses is installed"
  else
    echo "Ncurses is not installed, installing ncurses since \"clear\" command is required..."
    sudo dnf update
    sudo dnf install -y ncurses
  fi
fi
