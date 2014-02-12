#!/bin/bash
find /bin /dev /etc /lib /sbin /usr /var -type l > /etc/postinstall/symlinks_broken.txt