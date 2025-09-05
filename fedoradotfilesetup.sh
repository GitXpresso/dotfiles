#!/bin/bash
start(){
number='^[0-9]'
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
    if [[ "$pick_an_option" == "1" ]]; then
      clear
    while true; do
      read -p "pick an number ( limit is 20 ): " pick_an_number
      if [ "$pick_an_number" -gt 20 ];
        echo "You've entered a number that is higher than 20, try again..."
        read -p "pick an number ( limit is 20 ): " pick_an_number
       else
         if echo "$pick_an_number" || grep -qi '^[0-9]'; then
           echo "max_parrell_downloads=$pick_an_number" | sudo tee -a /etc/dnf/dnf.conf
         fi
       fi
        else
           echo "Not a number, try again..."
        fi
     done
     elif [[ "$pick_an_option" == "2" ]]; then
          echo "max_parrell_downloads=3" | sudo tee -a /etc/dnf/dnf.conf
     fi
   else
     echo "invaild option, try again..."
     sleep 0.2
     clear
     fi
  done
fi
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
