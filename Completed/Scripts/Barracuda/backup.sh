#!/bin/bash

#define variables
FILENAME1=CC-tree_`date +%d_%m_%Y_%H_%M`.par
FILENAME2=CC-box_`date +%d_%m_%Y_%H_%M`.par

#prerequisites
if [ ! -d "/mnt/barracuda" ]; then
    mkdir /mnt/barracuda
else
    echo "directroy already exists" >> /mnt/barracuda/log.txt 
fi

if mount | grep /mnt/barracuda > /dev/null; then
    echo "already mounted" >> /mnt/barracuda/log.txt 
else
    mount -t cifs -o user=barracuda -o password=T4brracudaadmin 
    //192.168.111.10/archief/barracuda_backup /mnt/barracuda
fi

echo "creating backup" >> /mnt/barracuda/log.txt 
#create par file (tree)
cd /opt/phion/rangetree/
/opt/phion/bin/phionar cdl /mnt/barracuda/${FILENAME1} ./configroot/*

#create par file (box)
cd /opt/phion/config/configroot/
/opt/phion/bin/phionar cdl /mnt/barracuda/${FILENAME2} *

sleep 5

if [ -f "/mnt/barracuda/${FILENAME1}" ]; then
    echo "$FILENAME1 exist" >> /mnt/barracuda/log_tree.txt 
else 
    echo "$FILENAME1 does not exist" >> /mnt/barracuda/log.txt 
fi

if [ -f "/mnt/barracuda/${FILENAME2}" ]; then
    echo "$FILENAME2 exist" >> /mnt/barracuda/log_box.txt 
else 
    echo "$FILENAME2 does not exist" >> /mnt/barracuda/log.txt 
fi
