#!/bin/bash
test_function(){
is_fast=$(grep -q "fastestmirror=True" /etc/dnf/dnf.conf && echo yes || echo no)
is_yes=$(grep -q "defaultyes=True" /etc/dnf/dnf.conf && echo yes || echo no)
is_delta=$(grep -q "deltarpm=True" /etc/dnf/dnf.conf && echo yes || echo no)
is_cache=$(grep -q "keepcache=True" /etc/dnf/dnf.conf && echo yes || echo no)
echo "
1. Add Fast Repositories (Allows faster dnf installs) [ Available = "$is_fast" ] 
2. Enable Default Prompt to \"Y\" instead of \"N\" when installing packages [ Available = "$is_yes" ] 
3. Enable DeltaRPM ( Downloads only the differences between package versions, saving bandwidth ) [ Available = "$is_delta" ] 
4. Set Keep Cache value to true ( Keeps the downloaded packages in cache, useful for reinstalls or debugging ) [ Available = "$is_cache" ]
"
read -p "Select more than one [Main] configuration [e.g. 1 3 or 1,2]: " pick_an_configuration
choices=$( echo $pick_an_configuration | tr ',' ' ')
for choice in $choices; do
   case "$choice" in
   
     1)
       if [ "$is_fast" == "no" ]; then
         touch ~/dnf.tmp
         if ! grep -q "[main]" /etc/dnf/dnf.conf; then
           echo "[main]" >> ~/dnf.tmp
         fi
         echo "fastestmirror=True" >> ~/dnf.tmp
         sudo cp ~/dnf.tmp /etc/dnf/dnf.conf
         rm -f ~/dnf.tmp
       else
         echo "Already configured, executing other options"
       fi
       ;;
     
     2)
       if [ "$is_yes" == "no" ]; then
         touch ~/dnf.tmp
         if ! grep -q "[main]" /etc/dnf/dnf.conf; then
           echo "[main]" >> ~/dnf.tmp
         fi
         echo "defaultyes=True" >> ~/dnf.tmp
         sudo cp ~/dnf.tmp /etc/dnf/dnf.conf
         rm -f ~/dnf.tmp
       else
         echo "Default prompt already enabled."
       fi
       ;;
     
     3)
       if [ "$is_delta" == "no" ]; then
         touch ~/dnf.tmp
         if ! grep -q "[main]" /etc/dnf/dnf.conf; then
           echo "[main]" >> ~/dnf.tmp
         fi
         echo "deltarpm=True" >> ~/dnf.tmp
         sudo cp ~/dnf.tmp /etc/dnf/dnf.conf
         rm -f ~/dnf.tmp
       else
         echo "DeltaRPM already configured."
       fi
       ;;
     
     4)
       if [ "$is_cache" == "no" ]; then
         touch ~/dnf.tmp
         if ! grep -q "[main]" /etc/dnf/dnf.conf; then
           echo "[main]" >> ~/dnf.tmp
         fi
         echo "keepcache=True" >> ~/dnf.tmp
         sudo cp ~/dnf.tmp /etc/dnf/dnf.conf
         rm -f ~/dnf.tmp
       else
         echo "KeepCache already configured."
       fi
       ;;
     
     *)
       echo "Invalid option."
       exit 1
       ;;
   esac
done
}
case "$1" in
   -test) 
   test_function
   ;;
   *)
   echo "Invalid option"
   exit 1
   ;;
esac
if grep -qi "Fedora" /etc/*release; then
  if rpm -q ncurses &>/dev/null; then
    echo "Ncurses is installed"
  else
    echo "Ncurses is not installed, installing ncurses since \"clear\" command is required..."
    sudo dnf update -y
    sudo dnf install -y ncurses
  fi

  while true; do
    read -p "Do you want to add some things to /etc/dnf/dnf.conf? (yes/no/y/n): " yesorno1
    if [[ "$yesorno1" == "yes" || "$yesorno1" == "y" ]]; then
      while true; do
    echo "
1. Add Fast Repositories (Allows faster dnf installs)
2. Enable Default Prompt to \"Y\" instead of \"N\" when installing packages
"
    read -p "Pick An Option [1-2]: " pick_an_option1

    if [[ "$pick_an_option1" == "1" ]]; then
      if ! grep -qi "fastestmirror=True" /etc/dnf/dnf.conf; then
        echo "Adding fastest mirror configuration..."
        echo "[main]"
        echo "fastestmirror=True" >> ~/dnf.tmp
        sudo cp ~/dnf.tmp /etc/dnf/dnf.conf
        rm -f ~/dnf.tmp
      else
        echo "Fastest mirror configuration already added."
      fi
      break
    elif [[ "$pick_an_option1" == "2" ]]; then
      if ! grep -qi "defaultyes=True" /etc/dnf/dnf.conf; then
        echo "Enabling default 'yes' prompt..."
        echo "defaultyes=True" >> ~/dnf.tmp
        sudo cp ~/dnf.tmp /etc/dnf/dnf.conf
        rm -f ~/dnf.tmp
      else
        echo "Default prompt already set to 'yes'."
      fi
      break
    else
      echo "Invalid option, try again..."
      sleep 0.2
      clear
    fi
  done

  while true; do
    clear
    read -p "Do you want to enable parallel downloads (yes/no/y/n): " yesorno2
    if [[ "$yesorno2" == "yes" || "$yesorno2" == "y" ]]; then
      while true; do
        clear
        echo "
1. Default Max Parallel Downloads \"3\"
2. Set custom amount of Parallel Downloads allowed
"
        read -p "Pick an option [1-2]: " pick_an_option2

        if [[ "$pick_an_option2" == "1" ]]; then
          if ! grep -q "max_parallel_downloads=3" /etc/dnf/dnf.conf; then
            echo "Setting max parallel downloads to 3..."
            echo "[main]" >> ~/dnf1.tmp
            echo "fastestmirror=True" >> ~/dnf1.tmp
            echo "max_parallel_downloads=3" >> ~/dnf1.tmp
            sudo cp ~/dnf1.tmp /etc/dnf/dnf.conf
            rm -f ~/dnf1.tmp
          else
            echo "max_parallel_downloads=3 already set."
          fi
          break 2  # Break out of both loops after setting
        elif [[ "$pick_an_option2" == "2" ]]; then
          while true; do
            read -p "Set your custom amount of parallel downloads allowed: " pick_an_number
            if echo "$pick_an_number" | grep '^[0-9]'; then
              echo "Setting max_parallel_downloads to $pick_an_number..."
              echo "[main]" >> ~/dnf.tmp
              echo "fastestmirror=True" >> ~/dnf.tmp
              echo "max_parallel_downloads=$pick_an_number" >> ~/dnf.tmp
              sudo cp ~/dnf.tmp /etc/dnf/dnf.conf
              rm ~/dnf.tmp
              break 3  # Break out of all loops after setting
            else
              echo "Not a valid number, try again..."
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
    elif [[ "$yesorno1" == "no" || "$yesorno1" == "n" ]]; then
      echo "Not making any changes to dnf.conf"
      exit 0
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

else
  echo "Not using Fedora, exiting..."
  exit 1
fi
