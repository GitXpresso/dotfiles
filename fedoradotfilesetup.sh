#!/bin/bash
if grep -qi "Fedora" /etc/*release; then
  if rpm -q ncurses; then
    echo "Ncurses is installed"
  else
    echo "Ncurses is not installed, installing ncurses since \"clear\" command is required..."
    sudo dnf update
    sudo dnf install -y ncurses
  fi
  while true; do
   read -p "Do you want to add some things to /etc/dnf/dnf.conf? (yes/no/y/n):" yesorno1
     if [[ "$yesorno1" == "yes" || "$yesorno1" == "y" ]]; then
        while true; do
          echo "
          1. Add Fast Repositories ( Allows faster dnf installs. )
          2. Enable Default Prompt to \"Y\" instead of \"N\" when installing packages.
          "
          read -p "Pick An Option [1-3]: " pick_an_option1
          if [[ "$pick_an_option1" == "1" ]]; then
                       while true; do
                               clear
                               read -p "Do want to enable parallel downloads ( allows to install multiple packages simultaneously (yes/no/y/n): " yesorno2
           if [[ "$yesorno2" == "yes" || "$yesorno2" == "y" ]]; then
           while true; do
             clear
             echo "
             1. Default Max Parallel Downloads \"3\"
             2. Set the custom amount of Parallel Downloads allowed
             "
             read -p "Pick an option [1-2]: " pick_an_option2
               if [ "$pick_an_option2" == "1" ]; then
                 echo "Setting max parallel downloads to 3"
                 if ! grep "max_parallel_downloads=3" /etc/dnf/dnf.conf; then
                   sudo echo "max_parallel_downloads=3" >> /etc/dnf/dnf.conf
                   break
                 else
                    echo "max_parrallel_downloads was already added to \"/etc/dnf/dnf.conf\""
                    return 1
                 fi
                 break
                 elif [ "$pick_an_option2" == "2" ]; then
                   while true; do
                     read -p "Set your custom amount of parallel downloads allowed: " pick_an_number
                       if ! grep "${1,10}" $pick_an_number; then
                         echo "Not a number try again..."
                         return 1
                       else
                         sudo echo "max_parallel_downloads=$pick_an_number" >> /etc/dnf.conf
                         break
                       fi
                     done
                    else
                        echo "invaild option try again..."
                        sleep 0.2
                        clear
                    fi
            done

           else
              echo "Invaild option try again..."
              sleep 0.2
              clear
           fi
           done
           else
              echo "Invaild option try again..."
              sleep 0.2
              clear
           fi
         done
        else
           echo "Invaild option try again..."
           sleep 0.2
           clear
        fi
     done
  else 
     echo "Invaild option try again..."
     sleep 0.2
     clear
  fi
  done
                  echo "
                  1. Add Fast Repositories ( Allows faster dnf installs. )
                  2. Enable Default Prompt to \"Y\" instead of \"N\" when installing packages.
                  "
                  read -p "Pick An Option [1-3]: " pick_an_option1
                    if [[ "$pick_an_option1" == "1" ]]; then
                       while true; do
                               clear
                               read -p "Do want to enable parallel downloads ( allows to install multiple packages simultaneously (yes/no/y/n): " yesorno2
                           if [[ "$yesorno2" == "yes" || "$yesorno2" == "y" ]]; then
                             while true; do
                               clear
                               echo "
                               1. Default Max Parallel Downloads \"3\"
                               2. Set the custom amount of Parallel Downloads allowed
                               "
                               read -p "Pick an option [1-2]: " pick_an_option2
                                 if [ "$pick_an_option2" == "1" ]; then
                                   echo "Setting max parallel downloads to 3"
                                   if ! grep "max_parallel_downloads=3" /etc/dnf/dnf.conf; then
                                     sudo echo "max_parallel_downloads=3" >> /etc/dnf/dnf.conf
                                     break
                                   else
                                     echo "max_parrallel_downloads was already added to \"/etc/dnf/dnf.conf\""
                                     return 1
                                   fi
                                   break
                                 elif [ "$pick_an_option2" == "2" ]; then
                                 while true; do
                                   read -p "Set your custom amount of parallel downloads allowed: " pick_an_number
                                     if ! grep "${1,10}" $pick_an_number; then
                                       echo "Not a number try again..."
                                       return 1
                                     else
                                       sudo echo "max_parallel_downloads=$pick_an_number" >> /etc/dnf.conf
                                       break
                                     fi
                                  
                                  done
                                  else
                                     echo "Invaild option try again..."
                                     sleep 0.2
                                     clear
                                  fi
                              done
                             else
                                 echo "Invaild option, try again..."
                                 sleep 0.2
                                 clear   
                             fi
                          done
             elif [[ "$yesorno1" == "no" || "$yesorno1" == "n" ]]; then
                 echo "Not making any changes to dnf.conf"
             else
                 echo "Invalid Option try again..."
                 sleep 0.2
                 clear
             fi
          done
          fi
