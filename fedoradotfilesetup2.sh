#!/bin/bash
red=$(tput setaf 1)
green=$(tput setaf 2)
no_color=$(tput sgr0)
gray=$(tput setaf 250)
color_status() {
  if [ "$1" == "yes" ]; then
    echo "${green}Enabled${no_color}"
  else
    echo "${red}Disabled${no_color}"
  fi
}

start(){
number='^[0-9]\+$'
is_fast=$(grep -q "fastestmirror=True" /etc/dnf/dnf.conf && echo yes || echo no)
is_yes=$(grep -q "defaultyes=True" /etc/dnf/dnf.conf && echo yes || echo no)
is_cache=$(grep -q "keepcache=True" /etc/dnf/dnf.conf && echo yes || echo no)
is_parallel_downloads=$(grep -q "max_parallel_downloads=$number" /etc/dnf/dnf.conf && echo yes || echo no)
echo "
1. Add Fast Repositories (Allows faster dnf installs) [ ${gray}Status${no_color} = $(color_status $is_fast) ] 
2. Enable Default Prompt to \"Y\" instead of \"N\" when installing packages. [ ${gray}Status${no_color} = $(color_status $is_yes) ] 
4. Set Keep Cache value to true (Keeps the downloaded packages in cache.) [ ${gray}Status${no_color} = $(color_status $is_cache) ]
5. Enable Parallel Downloads ( installs multiple packages simultaneously.) [ ${gray}Status${no_color} = $(color_status $is_parallel)]
"
read -p "Select more than one [Main] configuration [e.g. 1 3 or 1,2]: " pick_an_configuration
choices=$( echo $pick_an_configuration | tr ',' ' ')
for choice in $choices; do
   case "$choice" in
   
     1)
       if [ "$is_fast" == "no" ]; then
         touch ~/dnf1.tmp
       else
         echo "Already configured, executing other options"
       fi
       clear
       ;;
     
     2)
       if [ "$is_yes" == "no" ]; then
         touch ~/dnf2.tmp
       else
         echo "Default prompt already enabled."
       fi
       clear
       ;;
     3)
       if [ "$is_cache" == "no" ]; then
         touch ~/dnf3.tmp
       else
         echo "KeepCache already configured."
       fi
       clear
       ;;
     4)
       if [ "$is_parallel" == "no" ]; then
         touch ~/dnf4.tmp
       else
          echo "KeepCache Already configured"
       fi
       clear
       ;;
     
     *)
       echo "Invalid option."
       exit 1
       ;;
   esac
done
if [ -f ~/dnf1.tmp ]; then
echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf > /dev/null 2>&1
fi
if [ -f ~/dnf2.tmp ]; then
echo "defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf > /dev/null 2>&1
fi
if [ -f ~/dnf3.tmp ]; then
echo "keepcache=True" | sudo tee -a /etc/dnf/dnf.conf > /dev/null 2>&1
fi
if [ -f ~/dnf4.tmp ]; then
  while true; do
    echo "
    1. Set custom limit to parrel; Downloads ( max limit: 20 )
    2. Default Parrell downloads: 3
    "
    read -p "pick an option [1-3]: " pick_an_option
 if [ "$pick_an_option" == "1" ]; then
   while true; do
    read -p "Pick a number (limit is 20): " pick_an_number

  # Check if input is a valid integer
    if echo "$pick_an_number" | grep -q '^[0-9]\+$'; then
      if [ "$pick_an_number" -le 20 ]; then
        echo "max_parallel_downloads=$pick_an_number" | sudo tee -a /etc/dnf/dnf.conf
        break
      else
        echo "You've entered a number higher than 20, try again..."
        sleep 0.5
        clear
      fi
    else
      echo "Not a number, try again..."
      sleep 0.5
      clear
   fi
done
  elif [ "$pick_an_option" == "2" ]; then
      echo "max_parallel_downloads=3" | sudo -tee -a /etc/dnf/dnf.conf
      break
  else
     echo "Invaild input, try again..."
     sleep 0.2
     clear
  fi
done
fi
if dnf repolist enabled | grep rpmfusion-free; then
  if_rpmfree="yes"
else
  if_rpmfree="no"
fi
if dnf repolist enabled | grep rpmfusion-nonfree; then
  if_rpmnonfree="yes"
else
  if_rpmnonfree="no"
fi

  while true; do
    read -p "Install RPM Fusion (free & non-free)? Enter 1 to list packages (yes/no/y/n): " yesorno4
     if [[ "$yesorno4" == "yes" || "$yesorno4" == "y" ]]; then
       echo "Checking if rpm fusion non-free or free is already installed."
         if [ "$if_rpmfree" == "yes" ]; then
           echo "RPM fusion free already installed, skipping..."
           sleep 0.2
           clear
         else
           echo "RPM  Fusion free not installed, installing..."
           sudo dnf install -y https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
           sleep 0.2 
           clear
         fi
         if [ "$if_rpmnon_free" == "yes" ]; then
           echo "RPM fusion non-free already installed."
           sleep 0.2
           clear
           echo "Done installing RPM Fusion."
           break
           sleep 0.2
           clear
         else
           echo "RPM Fusion non-free not installed, installing..."
           sudo dnf install -y https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
           sleep 0.2
           clear
           echo "Done installing RPM Fusion repositories."
           sleep 0.2 
           clear
           break
         fi
         elif [[ "$yesorno4" == "no" || "$yesorno4" == "n" ]]; then
             echo "Not installing RPM-Fusion repositories."
             break
             exit 1
         elif [[ "$yesorno4" == "1" ]]; then
          while true; do
           echo "
           1. Free
           2. Non-Free
           "
         read -p "Pick an RPM-Fusion repository to list: " pick_an_repository
          if [[ "$pick_an_repository" == "1" ]]; then
            echo "Listing all RPM Fusion free repository packages."
            clear
            free_packages=$(curl -fsSL https://raw.githubusercontent.com/GitXpresso/dotfiles/refs/heads/main/rpm-fusion-free-list.txt)
            echo "$free_packages"
            read -p "Press any key to clear..."
            clear
            break
          elif [[ "$pick_an_repository" == "2" ]]; then
              echo "Listing all RPM Fusion non-free repository packages."
              clear
              non_free_packages=$(curl -fsSL https://raw.githubusercontent.com/GitXpresso/dotfiles/refs/heads/main/rpm-fusion-non-free-list.txt)
              echo "$non_free_packages"
              read -p "Press any key to clear..."
              clear
              break
          else
            echo "Invalid option, try again."
            sleep 0.2 
            clear
         fi
       done
  
    else
      echo "Invalid input, try again..."
      sleep 0.2
      clear
    fi
done
  while true; do
   read -p "Do you want to install a browser? (yes/no/y/n): " yesorno5
    if [[ "$yesorno5" == "yes" || "$yesorno5" == "y" ]]; then
      while true; do 
      echo "
      1. Firefox And Firefox-based browsers
      2. Chromium and Chromium-based browsers
      3. Ladybird ( ${gray}Fully Released${no_color} = ${red}no${no_color} ) [ Not an option yet...]
      "
      read -p "Pick an browser [1-2]: " pick_a_browser
      if [[ "$yesorno" == "1" ]]; then
      if [ -f /usr/bin/firefox ]; then 
       if_firefox="${green}yes${no_color}"
     else
       if_firefox="${red}no${no_color}"
     fi
      while true; do 
        echo "
        1 Firefox ( a browser that claims to \"rebuild the internet\") [ Firefox Installed = $if_firefox ]
        2. Floorp
        3. Librewolf ( Privacy-focused browser )
        4. Waterfox ( fork of firefox )
        5. Tor ( The onion routing )
        6. Icecat
        8. Mullvad ( Kinda Like of tor but using a vpn instead ) 
        9. Zen Novnc ( customizable browser ) 
        10. Pale Moon ( brings back the old firefox UI )
        11. Midori NoVNC 
        12. Pulse ( Kinda of like zen but longer maintained. ) 
        13. Basilisk 
        "
        read -p "Pick an firefox or firefox-based browser to install. [1-11]: " firefox_browsers
        for browser in ${firefox_browsers}; do
           case in ${firefox_browsers}
             1)
             if [ ! /usr/bin/firefox ]; then
               sudo dnf install -y firefox
               echo "Firefox is now installed"
             ;;

             2)

             ;;

             3)

             ;;

             4)
             if [ rpm -q | grep -qw "waterfox"; then
               echo "Waterfox is not installed, installing..."
               waterfox_version="6.6.3"
               wget -P ~/ https://github.com/GitXpresso/LinuxPKG/releases/download/Waterfox/waterfox-$waterfox_version-2.x86_64.rpm
               sudo dnf install -y ~/waterfox-$waterfox_version*.rpm
               clear
               echo "Waterfox is now installed, run waterfox by doing \"waterfox\" in the terminal or run waterfox from the start menu"
            else
               echo "waterfox is already installed"
            fi

             ;;

             5)

             ;;

             6)

             ;;

             7)

             ;;

             8)

             ;;

             9)

             ;;

             10)

             ;;

             11)

             ;;

             12)

             ;;

             13)

             ;;

             *)
             echo "Invalid option, try again..."
             ;;
         esac
      done   
        else
           echo "Invalid option, try again..."
        fi
      done
      else
         echo "Invalid option, try again..."
         sleep 0.2
         clear
      fi
    done
  else
    echo "Invalid option, try again..."
    sleep 0.2
    clear
  fi
done
         
}
if grep -qi "Fedora" /etc/*release; then
#case "$1" in
   #--test) 
   #test_function
   #;;
#esac
  if rpm -q ncurses &>/dev/null; then
    echo "Ncurses is installed"
    clear
  else
    echo "Ncurses is not installed, installing ncurses since \"clear\" command is required..."
    sudo dnf update -y
    sudo dnf install -y ncurses
  fi
  clear
  start
else
   echo "not using fedora, exiting..."
   exit 1
fi
