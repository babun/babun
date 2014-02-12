#!/bin/bash
find /bin /dev /etc /lib /sbin /usr /var -type l > /etc/postinstall/fix_broken_links.txt