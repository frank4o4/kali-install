#!/bin/sh

# Define a variable for the username
USERNAME="frank4o4"


# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo or run as root user."
  exit 1
fi


# Install Visual Code
cd /tmp &&
wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O /tmp/code_latest_amd64.deb &&
sudo dpkg -i code_latest_amd64.deb &&
rm code_latest_amd64.deb &&

# Install Tools
# Will add more as I notice the ones I use are missing
sudo apt update 
sudo apt install feroxbuster -y &&

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


# SOAPUI
wget https://dl.eviware.com/soapuios/5.7.2/SoapUI-x64-5.7.2.sh -O /tmp/soapui.sh &&
chmod 775 /tmp/soapui.sh &&
sudo /tmp/soapui.sh &&


# IDAPRO

wget https://out7.hex-rays.com/files/idafree84_linux.run -O /tmp/idapro.sh &&
chmod 775 /tmp/idapro.sh &&
sudo /tmp/idapro.sh


ida_icon="
[Desktop Entry]
Type=Application
Name=IDAPRO
Icon=/opt/idafree-8.4/appico64.png
Exec=/usr/bin/ida64
Terminal=false
Categories=Development;
"
echo "$ida_icon" | sudo tee -a /usr/share/applications/idapro.desktop > /dev/null


# jd-gui
wget https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-1.6.6.deb -O /tmp/jd-gui &&
sudo dpkg -i /tmp/jd-gui &&
rm /tmp/jd-gui &&

# Add my tools to /var/www/html

# Don't want users to know what my webserver is running
sudo rm /var/www/html/index* &&
sudo touch /var/www/html/index.html
cd /tmp
git clone https://github.com/frank4o4/kali-tools.git &&
cd kali-tools &&
rm README.md &&
sudo mv * /var/www/html &&
cd /tmp &&
sudo rm -rf /tmp/kali-tools &&
sudo rm /tmp/soapui.sh &&
sudo rm /tmp/idapro.sh &&

echo "Script Has completed"