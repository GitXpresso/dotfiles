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
