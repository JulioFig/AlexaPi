#! /bin/bash
cwd=`pwd`
if [ "$EUID" -ne 0 ]
	then echo "Please run as root"
	exit
fi

chmod +x *.sh

read -p "Would you like to also install Airplay support (Y/n)? " shairport

case $shairport in
        [nN] ) 
        	echo "shairport-sync (Airplay) will NOT be installed."
        ;;
        * )
        	echo "shairport-sync (Airplay) WILL be installed."
        ;;
esac

read -p "Would you like to add always-on monitoring (Y/n)? " monitorAlexa

case $monitorAlexa in
        [nN] ) 
        	echo "monitoring will NOT be installed."
        ;;
        * )
        	echo "monitoring WILL be installed."
        ;;
esac

apt-get update
apt-get install wget git -y


cd $cwd

wget --output-document vlc.py "http://git.videolan.org/?p=vlc/bindings/python.git;a=blob_plain;f=generated/vlc.py;hb=HEAD"
apt-get install python-dev swig libasound2-dev memcached python-pip python-alsaaudio vlc -y
pip install -r requirements.txt
touch /var/log/alexa.log

case $shairport in
        [nN] ) ;;
        * )
                echo "--building and installing shairport-sync--"
                cd /root
                apt-get install autoconf libdaemon-dev libasound2-dev libpopt-dev libconfig-dev avahi-daemon libavahi-client-dev libssl-dev libsoxr-dev -y
                git clone https://github.com/mikebrady/shairport-sync.git
                cd shairport-sync
                autoreconf -i -f
                ./configure --with-alsa --with-avahi --with-ssl=openssl --with-soxr --with-metadata --with-pipe --with-systemd
                make
                getent group shairport-sync &>/dev/null || sudo groupadd -r shairport-sync >/dev/null
                getent passwd shairport-sync &> /dev/null || sudo useradd -r -M -g shairport-sync -s /usr/bin/nologin -G audio shairport-sync >/dev/null
                make install
                systemctl enable shairport-sync
                cd $cwd
                rm -r /root/shairport-sync
        ;;
esac

case $monitorAlexa in
        [nN] ) 
		cp initd_alexa.sh /etc/init.d/AlexaPi
	;;
        * )
		cp initd_alexa_monitored.sh /etc/init.d/AlexaPi
        ;;
esac

update-rc.d AlexaPi defaults

echo "--Creating creds.py--"
echo "Enter your Device Type ID:"
read productid
echo ProductID = \"$productid\" > creds.py

echo "Enter your Security Profile Description:"
read spd
echo Security_Profile_Description = \"$spd\" >> creds.py

echo "Enter your Security Profile ID:"
read spid
echo Security_Profile_ID = \"$spid\" >> creds.py

echo "Enter your Client ID:"
read cid
echo Client_ID = \"$cid\" >> creds.py

echo "Enter your Client Secret:"
read secret
echo Client_Secret = \"$secret\" >> creds.py

python ./auth_web.py 
