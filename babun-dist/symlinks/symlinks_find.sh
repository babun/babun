#!/bin/bash
/bin/find /bin /dev /etc /lib /sbin /usr /var -type l -xtype l > /etc/postinstall/symlinks_broken.txt
