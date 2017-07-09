# BT Home Hub 5 Device List

A simple bash script to display a list of new/unknown devices connected to a BT Home Hub 5.

Each time the script is executed, all new/unknown devices are outputted and saved to a file.

This script is not robust and has a very niche use. It only works with a BT Home Hub 5. You may have to edit the script if your router IP address is different from the default (192.168.1.254).

By default, the file used for storing the known devices is .known-devices.txt (relative to the directory where you are running the script). Change this if you need to.

The main command of the script that is used to download and format the BT Home Hub control panel page is messy and could likely be improved. BT really did make it as difficult as possible to scrape data from their control panel pages, since the majority of the source HTML for the page is contained within just one line. I don't know if this is deliberate obfuscation or not.

Keep in mind that I designed the script not to be read directly by a human, but rather to be used as an input for another program. See "Use Cases" as the bottom of this README file.

## Example Output:

    jamie@box:~$ ./device-list.sh
    OfficeComputer_01:23:45:67:89:ab_192.168.1.2
    KitchenComputer_cd:ef:98:76:54:32_192.168.1.3
    AndroidDevice_56:78:9a:bc:de:f0_192.168.1.4
    iPhone_fe:dc:ba:98:76:54_192.168.1.5

## How does it work?

The script works by downloading the homepage of the router control panel, which has a table containing all of the devices connected to the network.

No form of authentication is required since all of the information needed can be loaded directly from the homepage. There is no need to log into with an administrator password.

Download and output the source HTML of the router control panel homepage:

    curl -s 192.168.1.254
    
Replace all less than signs with a newline character. This splits the messy single-lined table into multiple lines, making it much more manageable:

    tr "<" "\n"
    
Filter the output to only lines containing this text. All of the data that is needed is contained within cells like this:

    grep "TD class=\"bt_border\" align=LEFT valign=MIDDLE width=\"2[35]%\">"
    
Filter out unwanted text and add newline characters to the end of some lines:
    
    sed -e "s/^TD class=\"bt_border\" align=LEFT valign=MIDDLE width=\"2[35]%\">//; s/&nbsp;//; s/2.4 GHz Wireless:/2.4 GHz Wireless:\n/; s/5 GHz Wireless:/\n5 GHz Wireless:\n/; s/Ethernet:/Ethernet:\n/; s/USB:/\nUSB:\n/"

Filter out lines containing MAC addresses, as well as the lines both before and after:

    grep -B 1 -A 1 [0-9a-f][0-9a-f]:[0-9a-f][0-9a-f]

Replace all newline characters with a space. This results with the entire output been on one line:

    tr '\n' ' '

Replace the double dashes encapsulated by spaces with a newline character. This results in each device entry having its own line:

    sed -e s/" -- "/"\n"/g
     
Replace spaces with underscores. This is useful as it makes handling the data in an array much easier:
     
    tr ' ' '_'
    
The final output of the above is saved into the array "devices".

Construct an array using the contents of file known-devices.txt. On first run, this will throw a file not found error:

    mapfile -t known < known-devices.txt
    
Construct an array consisting any entires that are only contained within the arrays once. This will either be new devices, or devices that have previously been connected but currently are not:

    diff=(`echo ${known[@]} ${devices[@]} | tr ' ' '\n' | sort | uniq -u`)

Print out entries that are not present in the list of known devices. This will only be new/unknown devices (or devices that have changed configuration, such as a new hostname or IP address). This output is saved to the known-devices.txt file for use next time the script runs:

    echo ${devices[@]} ${diff[@]} | tr ' ' '\n' | sort | uniq -D | uniq | tee -a known-devices.txt

## Use Cases:

The output of this script could be put into an email and sent in order to be notified whenever a new device connects to your home network.

You could also use it with the notify-send (or equivalent) command on your Linux desktop.

Or write the output along with a timestamp to a file to keep a log of new devices that connect to your network.
