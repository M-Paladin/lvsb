# Home Cluster deployment
## initialisation_raspberry_pi.sh
Launch this script from your computer with a SD card connected.
It will be used to initialize the Raspberry Pi once it starts (DietPi unattended install).
Then the script "install_pxe_server.sh" will be executed from the raspberry pi thanks to AUTO_SETUP_CUSTOM_SCRIPT_EXEC parameter in dietpi.txt

## install_pxe_server.sh
This script will be launched at Raspberry Pi DietPi startup (AUTO_SETUP_CUSTOM_SCRIPT_EXEC).
It will :
- initialize DHCP/PXE server
- prepare Debian unattended installation
- install ansible (?)