#!/bin/bash

echo "installing packages..." && \
sudo pacman -S tomcat-native libvncserver freerdp nginx certbot certbot-nginx && \
wget --show-progress https://apache.org/dyn/closer.lua/guacamole/1.5.5/source/guacamole-server-1.5.5.tar.gz && \
tar -xvf guacamole-server-1.5.5.tar.gz && \
sleep 0.5 && clear && \
cd guacamole-server-1.5.5 && \ 
echo "building..." && \
./configure --with-init-dir=/etc/init.d && \ 
make && \
sudo make install && \
sudo systemctl start guacd && \
sudo systemctl enable guacd && \
wget --show-progress https://apache.org/dyn/closer.lua/guacamole/1.5.5/binary/guacamole-1.5.5.war?action=downloa && \
sudo cp guacamole-1.5.5.war /var/lib/tomcat/webapps/guacamole.war && \
sudo systemctl restart tomcat && \ 
sudo systemctl enable --now && \
echo "
server {
    listen 80;
    server_name gitxpressoal.duckdns.org;

    location / {
        proxy_pass http://localhost:8080/guacamole/;
        proxy_http_version 1.1;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
    }
}

" > ./guacamole && sudo mv ./guacamole /etc/nginx/sites-available/
sudo ln -s /etc/nginx/sites-available/guacamole /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl restart nginx
sudo certbot --nginx -d gitxpressoal.duckdns.org
sleep 0.5
clear
echo "Finished"
