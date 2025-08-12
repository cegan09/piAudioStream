# piAudioStream
Automatic install script to get a pi zero 2w streaming audio on rtsp

I wrote this script so that I wouldn't have to relearn how to set this up every time I wanted to configure another device. 
At home I run [birdNET-pi](https://github.com/Nachtzuster/BirdNET-Pi) and [birdNET-go](https://github.com/tphakala/birdnet-go), however rather than install multiple pi4s to each run their own server, I use pi zero 2s to stream audio over rtsp and then a single birdnet device to injest those streams and process them. 
This script should take a newly flashed Pi Zero 2 and get it configured and streaming audio. 

### Tested Hardware
The following devices and OS combinations have been tested
 - Pi Zero 2W + Pi OS Lite 64bit - bookworm: Confirmed working
 - Pi Zero W V1.1 + Pi OS Lite 32bit - bookworm: Script installs and service runs, however a single stream will max out the CPU. This combination may work, but may not be perfect

### How To Use
1. Review the files and scripts before downloading and running, you should understand what you're running before blindly trusting internet strangers
2. Download or clone the files to a local folder
3. Make the install.sh script executable with chmod +x
4. Make sure your audio device is plugged in before running the install as the script will prompt you to confirm which device to use and update the files accordingly
5. Run the install.sh script
6. When prompted, enter the audio devcice to use. There should normally only be 1 option if you're using a brand new install and only have a single usb device plugged in.
7. The script will run and at the end show the rtsp address to use elsewhere


### BirdNET-pi and Hardware Notes
#### Microphones and Sound Cards
I've been using the PUI AOM-5024L-HD-R with great success - https://www.mouser.com/ProductDetail/665-AOM-5024L-HD-R
These work great for localized recording. If you are trying to listen to a broad area, or far away sounds you may want to look into other solutions. 

Follow this guide for wiring the microphone modules for use - https://github.com/mcguirepr89/BirdNET-Pi/discussions/39#discussioncomment-2180372
I have used both ugreen devices listed in that post with good success. The Dual TRS device will allow you to wire up two microphones in stero, the TRRS device will only allow a single microphone. 
For wiring the TRS or TRRS connectors, reference this page - https://github.com/mcguirepr89/BirdNET-Pi/wiki/Microphones-and-USB-audio-sound-cards-for-BirdNET-Pi

Be sure to use a USB extension to separate the audio cards from the Pi for electrical reasons. The pi zero will require a USB micro to USB A adaptor anyway. 
