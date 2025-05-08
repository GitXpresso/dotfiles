git clone https://aur.archlinux.org/guacamole-server.git && \
cd guacamole-server && \
makepkg -si 

sudo systemctl enable guacd
sudo systemctl start guacd

wget https://archive.apache.org/dist/guacamole/1.5.4/binary/guacamole-1.5.4.war && \
sudo mv guacamole-1.5.4.war /usr/share/tomcat10/webapps/guacamole.war && \
sudo systemctl enable tomcat10 && \
sudo systemctl start tomcat10 

/etc/guacamole/guacamole.properties
echo "
guacd-hostname: localhost
guacd-port: 4822
" > ./guacamole.properties; sudo mv guacamole.properties
sudo mkdir -p /etc/guacamole
echo "GUACAMOLE_HOME=/etc/guacamole" | sudo tee -a /etc/default/tomcat10

/etc/guacamole/user-mapping.xml to define users:
echo "
<user-mapping>
    <authorize username="guacd-admin" password="guacd-admin">
        <connection name="Arch i3wm Desktop">
            <protocol>rdp</protocol>
            <param name="hostname">127.0.0.1</param>
            <param name="port">3389</param>
        </connection>
    </authorize>
</user-mapping>
" > ./user-mapping.xml; sudo mv ./user-mapping.xml /etc/guacamole/

echo "
server {
    listen 80;
    server_name gitxpressoal.duckdns.org;

    location / {
        proxy_pass http://localhost:8080/guacamole/;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $http_connection;
        proxy_set_header Host $host;
    }
}
" > ./guacamole; mv guacamole /etc/nginx/sites-available/
sudo systemctl enable nginx
sudo systemctl start nginx

<< if grep 'sudo apt update' ~/.bash_history; then
   echo "system is already updated"
else
   echo "system is not updated, updating system..."
   sudo apt update
   clear
   echo "finished updating."
fi
   sleep 0.5
   clear

if [ -f /usr/bin/zrok ]; then

   echo "zrok is installed."
   exit 1
else
   echo "Zrok is not installed, installing..."
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
   wget https://github.com/openziti/zrok/releases/download/v1.0.3/zrok_1.0.3_linux_amd64.tar.gz -q --show-progress
   sleep 0.5
   clear
   echo "done downloading zrok tar file."
   echo "Extracting tarfile..."
   tar -xf zrok_1.0.3_linux_amd64.tar.gz -C ~/
   echo "done extracting, moving zrok to /usr/bin..."
   sudo mv ~/zrok /usr/bin
   sleep 0.5
   clear
   echo "zrok is located at $(whereis zrok)"
   sleep 0.5
   clear
   echo "finished, to run zrok do: 'zrok'"
fi
if [ -d /etc/pacman.d ]; then
   echo "checking if you updated your system"
if grep -q 'sudo pacman -Syu' ~/.bash_history; then
   echo "system already updated, not updating system."
else 
   echo "did not update your system, updating..."
   sudo pacman -Syu
fi
   sleep 0.5
   clear
   echo "installing required packages..."
if [ -f /usr/bin/tar ]; then
   echo "tar is installed, checking if wget is installed..."
else
   echo "tar is not installed installing..."
   sudo pacman -S tar -y
   clear
   echo "tar is installed checking if wget is installed..."
fi
   sleep 0.5
   clear
if [ -f /usr/bin/wget ]; then
   echo "wget is installed, installing zrok..."
else
   echo "wget is not installed, installing..."
   sleep 0.5
   clear
   sudo pacman -S wget -y
   clear
   echo "wget is installed, installing zrok..."
fi
   echo "downloading zrok tarfile..."
   wget https://github.com/openziti/zrok/releases/download/v1.0.3/zrok_1.0.3_linux_amd64.tar.gz -q --show-progress
   sleep 0.5
   clear
   echo "done downloading zrok tar file."
   echo "moving zrok to /usr/bin"
   sudo mv ~/zrok /usr/bin
   echo "zrok is located at $(whereis zrok)"
   sleep 0.5
   clear
   echo "finished, to run zrok do: 'zrok'"
   rm zrok_1.0.3_linux_amd64*.tar.gz
fi
fi

if [ -f /usr/bin/apt ]; then
if grep 'sudo apt update' ~/.bash_history; then
   echo "system is already updated"
else
   echo "system is not updated, updating system..."
   sudo apt update
   clear
   echo "finished updating, installing zrok after this prompt"
fi
   sleep 0.5
   clear
read -p "do you want to install librewolf ( once ladybird browser releases this will be replaced? (yes/no): " yesorno
if [ $yesorno == yes ]; then
   echo "installing extrepo..."
   sudo apt install extrepo -y
   sleep 0.5 
   clear
   echo "installing librewolf..."
   sudo extrepo enable librewolf -y
   sleep 0.5 
   clear
   echo "librewolf is installed, installing zrok..."
   sudo apt install librewolf -y
elif [ $yesorno == no ]; then
     echo "not installing librewolf."
else
     echo "invalid input."
fi
if [ -f /usr/bin/zrok ]; then

   echo "zrok is installed."
   exit 1
else
   echo "Zrok is not installed, installing..."
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
   wget https://github.com/openziti/zrok/releases/download/v1.0.3/zrok_1.0.3_linux_amd64.tar.gz -q --show-progress
   sleep 0.5
   clear
   echo "done downloading zrok tar file."
   echo "Extracting tarfile..."
   tar -xf zrok_1.0.3_linux_amd64.tar.gz -C ~/
   echo "done extracting, moving zrok to /usr/bin..."
   sudo mv ~/zrok /usr/bin
   sleep 0.5
   clear
   echo "zrok is located at $(whereis zrok)"
   sleep 0.5
   clear
   echo "finished, to run zrok do: 'zrok'"
fi
if [ -d /etc/pacman.d ]; then
   echo "checking if you updated your system"
if grep -q 'sudo pacman -Syu' ~/.bash_history; then
   echo "system already updated, not updating system."
else 
   echo "did not update your system, updating..."
   sudo pacman -Syu
fi
   sleep 0.5
   clear
   echo "installing required packages..."
if [ -f /usr/bin/tar ]; then
   echo "tar is installed, checking if wget is installed..."
else
   echo "tar is not installed installing..."
   sudo pacman -S tar -y
   clear
   echo "tar is installed checking if wget is installed..."
fi
   sleep 0.5
   clear
if [ -f /usr/bin/wget ]; then
   echo "wget is installed, installing zrok..."
else
   echo "wget is not installed, installing..."
   sleep 0.5
   clear
   sudo pacman -S wget -y
   clear
   echo "wget is installed, installing zrok..."
fi
   echo "downloading zrok tarfile..."
   wget https://github.com/openziti/zrok/releases/download/v1.0.3/zrok_1.0.3_linux_amd64.tar.gz -q --show-progress
   sleep 0.5
   clear
   echo "done downloading zrok tar file."
   echo "moving zrok to /usr/bin"
   sudo mv ~/zrok /usr/bin
   echo "zrok is located at $(whereis zrok)"
   sleep 0.5
   clear
   echo "finished, to run zrok do: 'zrok'"
   rm zrok_1.0.3_linux_amd64*.tar.gz
fi
fi
>> 
