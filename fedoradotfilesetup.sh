#!/bin/bash
start(){
number='^[0-9]\+$'
is_fast=$(grep -q "fastestmirror=True" /etc/dnf/dnf.conf && echo yes || echo no)
is_yes=$(grep -q "defaultyes=True" /etc/dnf/dnf.conf && echo yes || echo no)
is_delta=$(grep -q "deltarpm=True" /etc/dnf/dnf.conf && echo yes || echo no)
is_cache=$(grep -q "keepcache=True" /etc/dnf/dnf.conf && echo yes || echo no)
is_parrell_downloads=$(grep -q "max_parallel_downloads=$number" /etc/dnf/dnf.conf && echo yes || echo no)

  echo "
1. Add Fast Repositories (Allows faster dnf installs) [ Available = $is_fast ] 
2. Enable Default Prompt to \"Y\" instead of \"N\" when installing packages [ Available = $is_yes ] 
3. Enable DeltaRPM (Downloads only the differences between package versions, saving bandwidth) [ Available = $is_delta ] 
4. Set Keep Cache value to true (Keeps the downloaded packages in cache, useful for reinstalls or debugging) [ Available = $is_cache ]
5. Enable Parrell Downloads ( installs multiple packages simultaneously ) [ Available = $is_parrell_downloads ]
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
       ;;
     
     2)
       if [ "$is_yes" == "no" ]; then
         touch ~/dnf2.tmp
       else
         echo "Default prompt already enabled."
       fi
       ;;
     
     3)
       if [ "$is_delta" == "no" ]; then
         touch ~/dnf3.tmp
       else
         echo "DeltaRPM already configured."
       fi
       ;;
     
     4)
       if [ "$is_cache" == "no" ]; then
         touch ~/dnf4.tmp
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
if [ -f ~/dnf1.tmp ]; then
echo "fastestmirror=True" | sudo tee -a /etc/dnf/dnf.conf
fi
if [ -f ~/dnf2.tmp ]; then
echo "defaultyes=True" | sudo tee -a /etc/dnf/dnf.conf
fi
if [ -f ~/dnf3tmp ]; then
echo "deltarpm=True" | sudo tee -a /etc/dnf/dnf.conf
fi
if [ -f ~/dnf4.tmp ]; then
echo "keepcache=True" | sudo tee -a /etc/dnf/dnf.conf
fi
if [ -f ~/dnf5.tmp ]; then
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
if_rpmfree=$(dnf repolist enabled | grep rpmfusion-free | echo yes | echo no)
if_rpmnon_free=$(dnf repolist enabled | grep rpmfusion-nonfree | echo | echo no)

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
          elif [[ "$pick_an_repository" == "2" ]]; then
              echo "Listing all RPM Fusion non-free repository packages."
              clear
              non_free_packages=$(curl -fsSL https://raw.githubusercontent.com/GitXpresso/dotfiles/refs/heads/main/rpm-fusion-non-free-list.txt)
              echo "$non_free_packages"
              read -p "Press any key to clear..."
              clear
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
  start
else
   echo "not using fedora, exiting..."
   exit 1
fi
