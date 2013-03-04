#!/bin/bash
#
# Post installation script for Fedora 18 Sperical Cow
#
# Syntax: sudo ./fedora18-postinstall.sh
#
# Boubakr NOUR <n.boubakr@gmail.com>
# Distributed under the GPL version 3 license


VERSION='0.1';

isRoot() {
	if [[ $EUID -ne 0 ]]; then
		return 0
	else
		return 1
	fi
}

checkInternet() {
	wget -q --tries=10 --timeout=5 http://www.google.com -O /tmp/index.google &> /dev/null
	if [ ! -s /tmp/index.google ];then
		return 0
	else
		return 1
	fi
}

is64() {
	arch=$(uname -m)

	if [ "$arch" == 'x86_64' ]
	then
	    return 1
	else
	    return 0
	fi

}

installArabicKeyboard() {
	echo "[!] Installing Arabic Keyboard..."
	gsettings set org.gnome.desktop.input-sources sources "[('xkb', 'us'), ('xkb', 'ara')]"
	gsettings set org.gnome.settings-daemon.peripherals.keyboard input-sources-switcher 'alt-shift'
}

geditEncoding() {
	echo "[!] Setting gedit encoding..."
	gsettings set org.gnome.gedit.preferences.encodings auto-detected "['UTF-8', 'CURRENT', 'UTF-16', 'WINDOWS-1256']"
	gsettings set org.gnome.gedit.preferences.encodings shown-in-menu "['UTF-8', 'WINDOWS-1256']"
}

totemEncoding() {
	echo "[!] Setting totem encoding..."
	gsettings set org.gnome.totem autoload-subtitles true
	gsettings set org.gnome.totem repeat true
	gsettings set org.gnome.totem subtitle-encoding 'WINDOWS-1256'
	gsettings set org.gnome.totem subtitle-font 'Sans Bold 14'
}

comonProblems() {
	echo "[!] Solving some problemes..."
	yum install -y gtk2-immodule-xim gtk3-immodule-xim
	gsettings set org.gnome.desktop.interface gtk-im-module 'xim'
	gsettings set org.gnome.desktop.interface document-font-name 'Sans 11'
	gsettings set org.gnome.desktop.interface clock-format '12h'
	gsettings set org.gnome.desktop.interface font-name 'Sans 11'
	gsettings set org.gnome.desktop.interface monospace-font-name 'Monospace 11'
	gsettings set org.gnome.desktop.interface buttons-have-icons true
	gsettings set org.gnome.desktop.interface menus-have-icons true

cat <<EOF >>/etc/X11/xinit/xinitrc.d/xim4arabic.sh
export GTK_IM_MODULE="xim"
export QT_IM_MODULE="xim"
EOF

}

disableSelinux() {
	echo "[!] Disabling selinux..."
	sed -i '/^\s*SELINUX/ s/=.*/=disabled/' /etc/selinux/config
}

saveYumPackages() {
	echo "[!] Setting yum to save packages when updating..."
	sed -i '/^keepcache/ s/=.*/=1/' /etc/yum.conf
}

enableAutomaticLogin() {
	echo "[!] Enabling automatic Login..."
	egrep -q AutomaticLoginEnable /etc/gdm/custom.conf || \
	sed -i '/^\[daemon\]/ aAutomaticLoginEnable=true\nAutomaticLogin=`whoami`' /etc/gdm/custom.conf
}

enableNumLock() {
	echo "[!] Enabling NumLock..."
	yum install -y numlockx
	egrep -q numlockx /etc/gdm/Init/Default || \
	sed -i '/exit 0/ i[ -x /usr/bin/numlockx ] && /usr/bin/numlockx on' /etc/gdm/Init/Default
}

installYumPlugins() {
	echo "[!] Installing yum plugins..."
	yum install -y yum-plugin-fastestmirror
}

installDevTools() {
	echo "[!] Installing Development tools..."
	yum groupinstall -y "Development tools"
}

installArabicFonts() {
	echo "[!] Installing Arabic support for LibbreOffice and Arabic fonts..."
	yum  install -y --nogpg http://ojuba.org/downloads/releases/16/Everything/i386/os/Packages/amiri-fonts-0.100-2.oj16.fc16.noarch.rpm http://ojuba.org/downloads/releases/16/Everything/i386/os/Packages/arabeyes-core-fonts-2.0.1-4.oj5.noarch.rpm http://ojuba.org/downloads/releases/16/Everything/i386/os/Packages/arabeyes-decorative-fonts-2.0.1-4.oj5.noarch.rpm http://ojuba.org/downloads/releases/16/Everything/i386/os/Packages/kacst-fonts-2.01-3.oj5.noarch.rpm http://ojuba.org/downloads/releases/16/Everything/i386/os/Packages/kfgqpc-fonts-0.08-1.oj4.noarch.rpm http://ojuba.org/downloads/releases/16/Everything/i386/os/Packages/msttcore-fonts-2.0-3.noarch.rpm
	yum groupinstall -y "arabic support" -x kacst*
}

installRPMFusion() {
	echo "[!] Installing RPMFusion..."
	yum localinstall -y --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-18.noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-18.noarch.rpm
	yum install -y --nogpg rpmfusion*
}

installProprietaryCodecs() {
	echo "[!] Installing Proprietary Codecs..."
	yum install -y gstreamer-* gstreamer1-* ffmpeg x264 unzip unrar p7zip --exclude=*devel,*doc*
}

installFlashPlayer() {
	echo "[!] Installing Adobe Flash Player..."
	yum install -y --nogpg http://linuxdownload.adobe.com/adobe-release/adobe-release-$(uname -m)-1.0-1.noarch.rpm
	yum install -y flash-plugin
}

installChrome() {
	echo "[!] Installing Google Chrome..."
cat <<EOF >> /etc/yum.repos.d/google-chrome.repo
[google-chrome]
name=google-chrome - 32-bit
baseurl=http://dl.google.com/linux/chrome/rpm/stable/i386
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub

[google-chrome]
name=google-chrome - 64-bit
baseurl=http://dl.google.com/linux/chrome/rpm/stable/x86_64
enabled=1
gpgcheck=1
gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pu
EOF

	yum install -y google-chrome-stable
}

installCinnamonDesktop() {
	echo "[!] Installing Cinnamon Desktop..."
	yum groupinstall -y "Cinnamon Desktop"
}

installMateDesktop() {
	echo "[!] Installing Mate Desktop..."
	yum groupinstall -y "Mate Desktop"
}

installSkype() {
	echo "[!] Installing Skype..."
	if [[ is64 ]]; then
		yum install -y alsa-lib.i686 fontconfig.i686 freetype.i686 glib2.i686 libSM.i686 libXScrnSaver.i686 libXi.i686 libXrandr.i686 libXrender.i686 libXv.i686 libstdc++.i686 pulseaudio-libs.i686 qt.i686 qt-x11.i686 zlib.i686 qtwebkit.i686
	fi
	cd /tmp
	wget --trust-server-names http://www.skype.com/go/getskype-linux-dynamic
	mkdir /opt/skype
	tar xvf skype-4.1* -C /opt/skype --strip-components=1

	ln -s /opt/skype/skype.desktop /usr/share/applications/skype.desktop
	ln -s /opt/skype/icons/SkypeBlue_48x48.png /usr/share/icons/skype.png
	ln -s /opt/skype/icons/SkypeBlue_48x48.png /usr/share/pixmaps/skype.png
	 
	touch /usr/bin/skype
	chmod 755 /usr/bin/skype

cat <<EOF >>/usr/bin/skype
#!/bin/sh
export SKYPE_HOME="/opt/skype"
 
$SKYPE_HOME/skype --resources=$SKYPE_HOME $*
EOF
}

#
# Here we go !
#

echo "Post installation script for Fedora 18 Sperical Cow"

if [[ checkInternet = 0 ]]; then
	echo "[x] There is no Internet connection..."
	exit 1
fi

if [[ isRoot ]]; then

	read -p "[-] Do you want disable selinux ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		disableSelinux
	fi

	clear
	read -p "Do you want to solve some problems ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		comonProblems
	fi

	clear
	read -p "[-] Do you want set yum to save packages when updating ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		saveYumPackages
	fi

	clear
	read -p "[-] Do you want to enable Automatic Login ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		enableAutomaticLogin
	fi

	clear
	read -p "[-] Do you want to enable NumLock ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		enableNumLock
	fi

	clear
	read -p "[-] Do you want to install yum plugins ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		installYumPlugins
	fi

	clear
	echo "[!] Updating the system..."
	yum update -y

	clear
	read -p "[-] Do you want to install Development tools ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		installDevTools
	fi

	clear
	read -p "[-] Do you want to install Arabic fonts ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		installArabicFonts
	fi

	clear
	read -p "[-] Do you want to install RPMFusion ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		installRPMFusion
	fi

	clear
	read -p "[-] Do you want to install Proprietary Codecs ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		installProprietaryCodecs
	fi

	clear
	read -p "[-] Do you want to install Adobe Flash Player ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		installFlashPlayer
	fi

	clear
	read -p "[-] Do you want to install Google Chrome ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		installChrome
	fi

	clear
	read -p "[-] Do you want to install Skype ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		installSkype
	fi

	clear
	read -p "[-] Do you want to install Cinnamon Desktop ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		installCinnamonDesktop
	fi

	clear
	read -p "[-] Do you want to install Mate Desktop ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		installMateDesktop
	fi

	clear
	read -p "[-] Do you want to install some utilities ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		yum install -y yumex thunderbird vlc terminator nautilus-open-terminal vim-enhanced gnome-tweak-tool
	fi


else

	echo "This script must be run as root..." 1>&2
	echo "Some stuff !"

	clear
	read -p "Do you want to install Arabic Keynoard ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		installArabicKeyboard
	fi

	clear
	read -p "Do you want to set gedit encoding ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		geditEncoding
	fi

	clear
	read -p "Do you want to set totem encoding ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		totemEncoding
	fi

	clear
	read -p "Do you want to solve some problems ? (y/n) " answer
	if [ "$answer" = 'y' ]; then
		comonProblems
	fi

	exit 1
fi