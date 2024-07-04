#!/bin/sh

# Exit script on any error
set -e

# Define a variable for the username
USERNAME="frank4o4"

# Check if the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "This script must be run as root. Please use sudo or run as root user."
  exit 1
fi

# Install Visual Code
cd /tmp
if wget 'https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64' -O /tmp/code_latest_amd64.deb; then
  sudo dpkg -i code_latest_amd64.deb
  rm code_latest_amd64.deb
else
  echo "Failed to download Visual Code"
fi

# Install Tools
sudo apt update
sudo apt install feroxbuster -y || echo "Failed to install feroxbuster"

# Samba Configuration
sudo sed -i 's/^client min protocol = LANMAN1/client min protocol = NT1/' /etc/samba/smb.conf

# Change to your username or remove if you don't plan on having samba shares
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

# Adding my user account as a samba user
sudo smbpasswd -a $USERNAME

# SOAPUI
if wget https://dl.eviware.com/soapuios/5.7.2/SoapUI-x64-5.7.2.sh -O /tmp/soapui.sh; then
  chmod 775 /tmp/soapui.sh
  sudo /tmp/soapui.sh
  sudo rm /tmp/soapui.sh
else
  echo "Failed to download SOAPUI"
fi

# IDAPRO
if wget https://out7.hex-rays.com/files/idafree84_linux.run -O /tmp/idapro.sh; then
  chmod 775 /tmp/idapro.sh
  sudo /tmp/idapro.sh
  sudo rm /tmp/idapro.sh
else
  echo "Failed to download IDAPRO"
fi

ida_icon="
[Desktop Entry]
Type=Application
Name=IDAPRO
Icon=/opt/idafree-8.4/appico64.png
Exec=/usr/bin/ida64
Terminal=false
Categories=Development;
"
echo "$ida_icon" > /usr/share/applications/idapro.desktop

# jd-gui
if wget https://github.com/java-decompiler/jd-gui/releases/download/v1.6.6/jd-gui-1.6.6.deb -O /tmp/jd-gui; then
  sudo dpkg -i /tmp/jd-gui
  rm /tmp/jd-gui
else
  echo "Failed to download jd-gui"
fi

# Add my tools to /var/www/html

# Don't want users to know what my webserver is running
sudo rm /var/www/html/index*
sudo touch /var/www/html/index.html
cd /tmp
if git clone https://github.com/frank4o4/kali-tools.git; then
  cd kali-tools
  rm README.md
  sudo mv * /var/www/html
  cd /tmp
  sudo rm -rf /tmp/kali-tools
else
  echo "Failed to clone kali-tools repository"
fi


# Pentesting Shell
cd /tmp &&
git clone https://github.com/frank4o4/Pentester-Shell.git &&
cd Pentester-Shell &&
sudo cp pentester_shell /home/$USERNAME/.pentester_shell &&
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/.pentester_shell &&
echo "source /home/$USERNAME/.pentester_shell" >> /home/$USERNAME/.zshrc &&
cd /tmp &&
sudo rm -rf Pentester-Shell


echo "Script has completed"
