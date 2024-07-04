#!/bin/sh

# Define a variable for the username
USERNAME="frank4o4"

# Install Visual Code
cd /tmp &&
wget https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 &&
sudo dpkg -i code* &&
rm code* &&

# Install Tools
# Will add more as I notice the ones I use are missing
sudo apt update 
sudo apt install feroxbuster &&

# Samba Configuration
# Support SMB1 Shares Scanning
sudo sed -i 's/^client min protocol = LANMAN1/client min protocol = NT1/' /etc/samba/smb.conf

# change to your username or remove if you don't plan on having samba shares
configurations="
[visualstudio]
path = /home/$USERNAME/data
browseable = yes
read only = no

[tools]
path = /var/www/html
guest ok = yes
read only = yes

[upload]
path = /home/$USERNAME/upload
browseable = yes
read only = no
"

# Append configurations to smb.conf
echo "$configurations" | sudo tee -a /etc/samba/smb.conf > /dev/null

# adding my user account as a samba user
sudo smbpasswd -a $USERNAME

# Add my tools to /var/www/html

# Don't want users to know what my webserver is running
sudo rm /var/www/html/index* &&
sudo touch /var/www/html/index.html
cd /tmp
git clone https://github.com/frank4o4/kali-tools.git &&
cd kali-tools &&
rm README.md &&
sudo mv * /var/www/html
