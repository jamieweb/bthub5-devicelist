#!/bin/bash
devices=($(curl -s 192.168.1.254 | tr "<" "\n" | grep "TD class=\"bt_border\" align=LEFT valign=MIDDLE width=\"2[35]%\">" | sed -e "s/^TD class=\"bt_border\" align=LEFT valign=MIDDLE width=\"2[35]%\">//; s/&nbsp;//; s/2.4 GHz Wireless:/2.4 GHz Wireless:\n/; s/5 GHz Wireless:/\n5 GHz Wireless:\n/; s/Ethernet:/Ethernet:\n/; s/USB:/\nUSB:\n/" | grep -B 1 -A 1 [0123456789abcdef][0123456789abcdef]:[0123456789abcdef][0123456789abcdef] | tr '\n' ' ' | sed -e s/" -- "/"\n"/g | tr ' ' '_'))

mapfile -t known < known-devices.txt

diff=(`echo ${known[@]} ${devices[@]} | tr ' ' '\n' | sort | uniq -u`)
echo ${devices[@]} ${diff[@]} | tr ' ' '\n' | sort | uniq -D | uniq | tee -a known-devices.txt
