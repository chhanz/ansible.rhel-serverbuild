#!/bin/bash
# remove virbr0
yum -y install libvirt-client
virsh net-destroy default
virsh net-undefine default
systemctl disable libvirtd
systemctl stop libvirtd
systemctl mask libvirtd
yum -y remove libvirt-client
