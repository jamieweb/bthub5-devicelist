# bthub5-devicelist

A simple bash script to display a list of new/unknown devices connected to a BT Home Hub 5.

Each time the script is executed, all new/unknown devices are outputted and saved to a file.

This script is not robust and has a very niche use. It only works with a BT Home Hub 5. You may have to edit the script if your router IP address is different from the default (192.168.1.254).

By default, the file used for storing the known devices is .known-devices.txt (relative to the directory where you are running the script). Change this if you need to.

The main command of the script that is used to download and format the BT Home Hub control panel page is messy and could likely be improved. BT really did make it as difficult as possible to scrape data from their control panel pages, since the majority of the source HTML for the page is contained within just one line.

## How does it work?

The script works by downloading the homepage of the router control panel, which has a table containing all of the devices connected to the network.

1. **curl -s 192.168.1.254**
   * Download and output the source HTML of the router control panel homepage.
2. **tr "<" "\n"**
   * Replace all less than signs with a newline character. This splits the messy single-lined table into multiple lines, making it much more manageable.
3. **grep "TD class=\"bt_border\" align=LEFT valign=MIDDLE width=\"2[35]%\">"**
   * Filter the output to only lines containing this text. All of the data that we want is contained within cells like this.
4. **sed -e "s/^TD class=\"bt_border\" align=LEFT valign=MIDDLE width=\"2[35]%\">//; s/&nbsp;//; s/2.4 GHz Wireless:/2.4 GHz Wireless:\n/; s/5 GHz Wireless:/\n5 GHz Wireless:\n/; s/Ethernet:/Ethernet:\n/; s/USB:/\nUSB:\n/"**
   * Filter out unwanted text and add newline characters to the end of some lines.
5. **grep -B 1 -A 1 [0123456789abcdef][0123456789abcdef]:[0123456789abcdef][0123456789abcdef]**
   * Filter out lines containing MAC addresses, as well as the lines both before and after.
6. **tr '\n' ' '**
   * Replace all newline characters with a space. This results with the entire output been on one line.
7. **sed -e s/" -- "/"\n"/g**
   * Replace the double dashes encapsulated by spaces with a newline character. This results in each device entry having its own line.
8. **tr ' ' '_'**
   * Replace spaces with underscores. This is useful as it makes handling the data in an array much easier.
