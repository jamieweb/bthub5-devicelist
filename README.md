# bthub5-devicelist

A simple bash script to display a list of new/unknown devices connected to a BT Home Hub 5.

Each time the script is executed, all new/unknown devices are outputted and saved to a file.

This script is not robust and has a very niche use. It only works with a BT Home Hub 5. You may have to edit the script if your router IP address is different from the default (192.168.1.254).

By default, the file used for storing the known devices is .known-devices.txt (relative to the directory where you are running the script). Change this is you need to.

The main command of the script that is used to download and format the BT Home Hub control panel page is messy and could likely be improved. BT really did make it as difficult as possible to scrape data from their control panel pages, since the majority of the source HTML for the page is contained within just one line.
