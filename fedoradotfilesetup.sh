if grep -qi "Fedora" /etc/*release; then
  if rpm -q ncurses; then
    echo "Ncurses is installed"
  else
    echo "Ncurses is not installed, installing ncurses since \"clear\" command is required..."
    sudo dnf update
    sudo dnf install -y ncurses
  fi
  while true; do
          read -p "Do you want Add somethings to /etc/dnf/dnf.conf? (yes/no/y/n): " yesorno1
            if [[ "$yesorno1" == "yes" || "$yesorno1" == "y" ]]; then
                while true; do
                  echo "
                  1. Add Fast Repositories ( Allows faster dnf installs. )
                  2. Enable Default Prompt to \"Y\" instead of \"N\" when installing packages.
                  "
                  read -p "Pick An Option [1-3]: " pick_an_option1
                    if [[ "$pick_an_option1" == "1" ]]; then
                       while true; do
                               read -p "Do want to enable parrel downloads ( allows to install multiple packages simultaneously (yes/no/y/n): " yesorno2
                           if [[ "$yesorno2" == "yes" || "$yesorno2" == "y" ]]; then
                             while true; do
                               read -p "Want to set Max Parrel downloads to default = \"3"

             elif [[ "$yesorno1" == "no" || "$yesorno1" == "n" ]]; then
                 echo "Not making any changes to dnf.conf"
             else
                 echo "Invalid Option try again..."
                 sleep 0.2
                 clear
             fi
          done
