#!/bin/sh
# Author  Achu Abebe
# Email:  Achusime@gmail.com 

# # You should run this with root privilage


#Variables
FQDN=dc1.local
DN=mydomain
NSE=8.8.8.8 #NS externe/forwarder
APW=Password@3
SHARE=/mnt/scripts/



#provision of field
/usr/local/samba/bin/samba-tool domain provision --realm=$FQDN --domain=$DN --adminpass="$APW" --server-role=dc --dns-backend=SAMBA_INTERNAL
#execution samba
/usr/local/samba/sbin/samba
#verification of versions samba and smbclient
/usr/local/samba/sbin/samba -V
/usr/local/samba/bin/smbclient -V
sleep 2
#Listing list of Samba users
/usr/local/samba/bin/smbclient -L localhost -U%
sleep 2
#verification of how authentication by connecting to the NETLOGON share with the administrator account
/usr/local/samba/bin/smbclient //localhost/netlogon -UAdministrator%"$APW" -c 'ls'

echo ================DNS CONFIGURATION SAMBA_INTERNAL=====================
# Configuration of Resolv.conf
echo domain $FQDN  >> /etc/resolv.conf
sed -i 's/.*dns forwarder =.*/	dns forwarder = 8.8.8.8/g' /usr/local/samba/etc/smb.conf # positioning forwarder
echo ====================DNS TEST==========================
#verification of the operation of DNS
host -t SRV _ldap._tcp.$FQDN.
host -t SRV _kerberos._udp.$FQDN.
host -t A $FQDN.
sleep 5
echo ==================KERBEROS CONFIGURATION==============
# deKerberos configuration
Newvariable=$( echo "$FQDN" | tr -s  '[:lower:]'  '[:upper:]' )
sed -i "s/\${REALM\([^}]*\)}"/$Newvariable"/g" /usr/local/samba/share/setup/krb5.conf
#verification of operation of Kerberos
kinit administrator@$Newvariable
klist -e

echo =================NTP CONFIGURATION====================
# Registration time servers and service configuration
 sed -i 's/0.debian.pool.ntp.org/0.fr.pool.ntp.org/' /etc/ntp.conf
 sed -i 's/1.debian.pool.ntp.org/1.fr.pool.ntp.org/' /etc/ntp.conf
 sed -i 's/2.debian.pool.ntp.org/2.fr.pool.ntp.org/' /etc/ntp.conf
 sed -i 's/3.debian.pool.ntp.org/3.fr.pool.ntp.org/' /etc/ntp.conf
service ntp restart
ntpdate 0.fr.pool.ntp.org
ntpq -p

echo =================HOMEFOLDERS CONFIGURATION============
#Configuration users homefolders
mkdir -m 770 /Users
chmod g+s /Users
chown root:users /Users

echo "
[Users]
directory_mode: parameter = 0700
read only = no
path = /Users
csc policy = documents" >> /usr/local/samba/etc/smb.conf

echo =================Startup script Samba4============
# Implementation of auto startup script for samba Upstart
cp $SHARE/samba4.conf /etc/init/
chmod 755 /etc/init/samba4.conf
chmod +x /etc/init/samba4.conf

echo ========================REBOOT==========================
exit
