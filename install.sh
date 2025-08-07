#!/bin/bash
# install.sh - Script to install and configure RTSP audio server on Raspberry Pi using GStreamer and a USB audio capture device
set -e

# Find current user in case it is not pi
echo "Detecting current user..."
CURRENT_USER=$(logname)
# print the current user
echo "Working as: $CURRENT_USER"
# Run an update on the system before making other changes
echo "Updating system..."
sudo apt update && sudo apt upgrade -y
# Install necessary dependencies for GStreamer and RTSP server
echo "Installing dependencies..."
sudo apt install -y \
  python3-gi \
  python3-gst-1.0 \
  gstreamer1.0-tools \
  gstreamer1.0-plugins-base \
  gstreamer1.0-plugins-good \
  gstreamer1.0-plugins-bad \
  gstreamer1.0-plugins-ugly \
  gstreamer1.0-libav \
  libgstrtspserver-1.0-dev \
  gir1.2-gst-rtsp-server-1.0
# Scan for audio capture devices
echo "🔍 Scanning for audio capture devices..."
mapfile -t devices < <(
  arecord -l | grep '^card' | while read -r line; do
    card_id=$(echo "$line" | sed -n 's/^card \([0-9]*\):.*/\1/p')
    device_id=$(echo "$line" | sed -n 's/.*device \([0-9]*\):.*/\1/p')
    label=$(echo "$line" | cut -d'[' -f2 | cut -d']' -f1)
    echo "$card_id,$device_id $label"
  done
)
# Error if none found
if [[ ${#devices[@]} -eq 0 ]]; then
  echo "No audio capture devices found."
  exit 1
fi
# Display the list of devices
echo
echo "Detected audio capture devices:"
for i in "${!devices[@]}"; do
  card_device=$(echo "${devices[$i]}" | cut -d' ' -f1)
  label=$(echo "${devices[$i]}" | cut -d' ' -f2-)
  echo "$((i+1)). [$card_device] - $label"
done
# Prompt user to select a device
echo
read -p "Enter the number of the device you want to use: " selection

if ! [[ "$selection" =~ ^[0-9]+$ ]] || (( selection < 1 || selection > ${#devices[@]} )); then
  echo "Invalid selection."
  exit 1
fi

selected="${devices[$((selection-1))]}"
card_device=$(echo "$selected" | cut -d' ' -f1)
label=$(echo "$selected" | cut -d' ' -f2-)
DEVICE_STRING="plughw:$card_device"

echo "You selected: $DEVICE_STRING  ($label)"

# Copy the python script to the /user/local/bin directory, make executable
echo "Copying script to /usr/local/bin..."
sudo cp rtsp_audio_server.py /usr/local/bin/
sudo chmod +x /usr/local/bin/rtsp_audio_server.py

# Create a systemd service file for the RTSP server
echo "Creating customized service file for $CURRENT_USER..."
# Replace "User=pi" with the actual username
sed "s/User=.*/User=$CURRENT_USER/" audio-stream.service > /tmp/audio-stream.service

echo "Installing systemd service..."
sudo cp /tmp/audio-stream.service /etc/systemd/system/audio-stream.service

# Replace the default device string in the Python script
sudo sed -i "s|plughw:[0-9],[0-9]|$DEVICE_STRING|" /usr/local/bin/rtsp_audio_server.py

# Reload systemd to recognize the new service, enable and start it
sudo systemctl daemon-reload
sudo systemctl enable audio-stream.service
sudo systemctl start audio-stream.service

# Check the status of the service
echo
sudo systemctl status audio-stream.service --no-pager


PI_IP=$(hostname -I | awk '{print $1}')
echo "Done! RTSP server should now be running."
echo "You can test it with: vlc rtsp://$PI_IP:8554/audio"

