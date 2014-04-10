# # !/bin/sh
# # Author  Achu Abebe
# # Author Email:  Achusime@gmail.com 
# # I'm from Ethiopia/Addis Ababa, If you have interesting project for me, Please contact me :) 
# # G+ https://plus.google.com/+AchuAbebe

# # You should run this with root privilage.
# Variables
IP=10.17.55.122
NM=255.255.255.0
NW=10.17.55.0
BC=10.17.55.255
GW=10.17.55.250
NSI=10.17.55.103 #NS interne
# NSI2= X.X.X.X
NSE=8.8.8.8 #NS externe/forwarder
# NSE2= X.X.X.X
FQDN=dc1.local 
HN=mydomain
ETH=eth0




echo ================NETWORK CONFIGURATION=======================

# parametrage network card in static mode and definition of IP parameters
sed -i 's/dhcp/static/g' /etc/network/interfaces
sed -i 's/eth/"$ETH"/g' /etc/network/interfaces
echo "	address $IP
	netmask $NM
	network $NW
	broadcast $BC
	gateway $GW
	dns-nameservers $NSI $NSE
	dns-search $FQDN ">> /etc/network/interfaces

# Configuring the hosts file
sed -i 's/127.0.0.1	localhost/127.0.0.1	localhost.localdomain	localhost/' /etc/hosts
sed -i  "s/127.0.1.1	$HN"/"$IP	$HN"."$FQDN	$HN"/"" /etc/hosts
# Configuration hostname file
echo $HN'.'$FQDN > /etc/hostname
/etc/init.d/hostname restart
/etc/init.d/networking restart
sleep 10
echo ================PREREQUISITES SETUP=====================
# mise a jour
apt-get update && apt-get upgrade -y
# Installing the necessary packages
apt-get install dialog git build-essential libacl1-dev libattr1-dev libblkid-dev libgnutls-dev libreadline-dev python-dev python-dnspython gdb pkg-config libpopt-dev libldap2-dev dnsutils libbsd-dev attr krb5-user docbook-xsl libcups2-dev libpam0g-dev ntp -y

echo ================SAMBA4 DOWNLOAD AND SETUP=====================
cd /
# Download Samba from git
git clone -b v4-0-stable https://git.samba.org/samba.git/ samba4
cd samba4
git clean -x -f -d # Disposal of obsolete files eventually
./configure --enable-debug --enable-selftest #Configuration
make # Compilation
make install # Installation
echo ========================REBOOT NOW==========================
exit
