#!/bin/bash
#
#
#
#   Make by. chhanz
#   Update date. 20190505
#
#

# Set value
DATE=`date +%y%m%d_%k%M`
RED='\033[0;31m'
NC='\033[0m'
LOGFILE=$(hostname)-preinstall-$DATE.log

# Check permission

if [ "$EUID" -ne 0 ]
  then echo -e "${RED}Please run as root ${NC}"
  exit
fi

# Stop Firewalld
echo -e "${RED}TURN OFF FIREWALLD${NC}" |tee -a $LOGFILE
systemctl stop firewalld
systemctl disable firewalld |tee -a $LOGFILE
echo "~"  |tee -a $LOGFILE

# Stop NetworkManager
echo -e "${RED}TURN OFF NETWORKMANAGER${NC}" |tee -a $LOGFILE
systemctl stop NetworkManager
systemctl disable NetworkManager |tee -a $LOGFILE
echo "~"  |tee -a $LOGFILE

# Disabled SELinux
echo -e "${RED}EDIT SELinux${NC}" |tee -a $LOGFILE
sed -i "s/^SELINUX=.*$/SELINUX=disabled/" /etc/selinux/config
cat /etc/selinux/config |tee -a $LOGFILE
setenforce 0
echo "~" |tee -a $LOGFILE

# CPU TUNING
echo -e "${RED}TUNE CPU${NC}" |tee -a $LOGFILE
cpupower frequency-set -g performance |tee -a $LOGFILE
for A in $(ls -l /sys/devices/system/cpu | grep cpu | sort | awk '{print $9}') ; do echo "$A Config : $(cat /sys/devices/system/cpu/$A/cpufreq/scaling_governor)" ; done |tee -a $LOGFILE
echo "~" |tee -a $LOGFILE

# DISABLE ctl+atl+del
echo -e "${RED}Disable ctrl-alt-del${NC}" |tee -a $LOGFILE
systemctl mask ctrl-alt-del.target |tee -a $LOGFILE
echo "~" |tee -a $LOGFILE

# Make Local repository
echo -e "${RED}Create Local Repository${NC}" |tee -a $LOGFILE
bash -c 'cat <<EOF > /etc/yum.repos.d/media.repo
[media]
name=media
baseurl=file:///root/OSC/base
enabled=1
gpgcheck=0
EOF'
ls -la /etc/yum.repos.d/media.repo |tee -a $LOGFILE
echo "~"  |tee -a $LOGFILE

# Copy media
echo -e "${RED}Copy media${NC}" |tee -a $LOGFILE
umount /dev/cdrom
echo " Ready Cdrom " |tee -a $LOGFILE
mkdir -p /root/OSC
mount /dev/cdrom /mnt |tee -a $LOGFILE
echo "Start Copy media" |tee -a $LOGFILE

### cp Command
#cp -rpH /mnt /root/OSC/base
echo "End Copy" |tee -a $LOGFILE
umount /dev/cdrom
echo "~" |tee -a $LOGFILE
yum clean all
yum repolist |tee -a $LOGFILE
echo "~"  |tee -a $LOGFILE

# Install GroupPackage

echo -e "${RED}INSTALL GROUPPACKAGES${NC}" |tee -a $LOGFILE
yum -y groupinstall "Server with GUI" "Compatibility Libraries" "Development Tools" "Legacy UNIX Compatibility" |tee -a $LOGFILE
yum -y install ntp |tee -a $LOGFILE

# SET RUNLEVEL
systemctl set-default graphical.target
echo "~"  |tee -a $LOGFILE

# Remove Package
echo -e "${RED}REMOVE Package${NC}" |tee -a $LOGFILE
rpm -qa | grep gnome-initial-setup | awk '{print "yum -y remove "$1}' | sh -x |tee -a $LOGFILE
# Add Any remove Package 
echo "~"  |tee -a $LOGFILE

# Disable chronyd
echo -e "${RED}CONFIG NTPD${NC}" |tee -a $LOGFILE
systemctl disable chronyd |tee -a $LOGFILE
systemctl stop chronyd
# Enable ntpd
systemctl enable ntpd |tee -a $LOGFILE
echo "~"  |tee -a $LOGFILE

# Create Template bond file
echo " * Template Files Created"  |tee -a $LOGFILE
mkdir -p /root/OSC/template
bash -c 'cat << EOF > /root/OSC/template/ifcfg-slave1
TYPE=Ethernet
BOOTPROTO=none
NAME=slave1
DEVICE=slave1
ONBOOT=yes
MASTER=bond0
SLAVE=yes
EOF'

bash -c 'cat << EOF > /root/OSC/template/ifcfg-slave2
TYPE=Ethernet
BOOTPROTO=none
NAME=slave2
DEVICE=slave2
ONBOOT=yes
MASTER=bond0
SLAVE=yes
EOF'

bash -c 'cat << EOF > /root/OSC/template/ifcfg-bond0
TYPE=Bond
BOOTPROTO=none
NAME=bond0
DEVICE=bond0
ONBOOT=yes
BONDING_OPTS="mode=1 miimon=100"
# Auto-FailBack-Disable-Option 
#BONDING_OPTS="mode=1 miimon=100 primary=<master> primary_reselect=2"
IPADDR=
NETAMSK=
GATEWAY=
EOF'

bash -c 'cat << EOF > /root/OSC/template/virt-network-remove.sh
#!/bin/bash

# remove virbr0
yum -y install libvirt-client
virsh net-destroy default
virsh net-undefine default
systemctl disable libvirtd
systemctl stop libvirtd
systemctl mask libvirtd
yum -y remove libvirt-client

EOF'

##############################
###  End of file
##############################

echo -e "${RED} * RHEL7 Preinstall Finish${NC}"  |tee -a $LOGFILE


