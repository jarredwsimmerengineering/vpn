#!/opt/homebrew/bin/bash

# Constants:
declare -r +i VpnPkgPath="$HOME/Downloads"
declare -r +i VpnPkgFilePath="$VpnPkgPath/vpn.pkg"
declare -r +i VpnInstallPath="$HOME/Applications"
declare -r +i VpnInstallFilePath="$VpnInstallPath/jarredwsimmerengineering.vpn"
declare -r +i VpnDownloadUrl='https://d20adtppz83p9s.cloudfront.net/OSX/latest/AWS_VPN_Client.pkg'
declare -r +i VpnCertificateDestinationPath="$VpnInstallFilePath/certificates"
declare -r +i VpnCertificateDestinationFilePath="$VpnCertificateDestinationPath/client-config.ovpn"
declare -r +i VpnTestHost='test.vpn.dev'


printf "Running $0...\n**********\n"

printf "Setting up VPN certificate...\n"
read -p 'Please enter the path to your VPN Certificate. If you do not have one, contact your system admin: ' vpnCertificatePath
while [ ! -f "$vpnCertificatePath" ]; do
	printf "The file path you've given is invalid. Please try again.\n"
	read -p 'Please enter the path to your VPN Certificate. If you do not have one, contact your system admin: ' vpnCertificatePath
done

if [ ! -d "$VpnInstallPath" ]; then
	mkdir $VpnInstallPath && chmod 700 $VpnInstallPath
fi

if [ ! -d "$VpnInstallFilePath" ]; then
	mkdir $VpnInstallFilePath && chmod 700 $VpnInstallFilePath
fi

if [ ! -d "$VpnCertificateDestinationPath" ]; then
	mkdir $VpnCertificateDestinationPath && chmod 700 $VpnCertificateDestinationPath
fi

cp $vpnCertificatePath $VpnCertificateDestinationFilePath

if [ ! -d "$VpnPkgPath" ]; then
	mkdir $VpnPkgPath && chmod 700 $VpnPkgPath
fi

printf "Downloading VPN client...\n"
curl $VpnDownloadUrl > $VpnPkgFilePath
printf "...finished\n"
printf "Installing VPN client. This will take a moment, and you may be asked to enter your password...\n"
sudo installer -pkg $VpnPkgFilePath -target $VpnInstallFilePath > /dev/null
printf "...finished\n"

printf "\nDo the following and press any key when done:\n"
printf "1. Open the application \"AWS VPN Client\"\n"
printf "2. Choose \"File\", \"Manage Profile\"\n"
printf "3. Choose \"Add Profile\"\n"
printf "4. For \"Display Name\", enter anything sensical, e.g. \"WorkVPN\"\n"
printf "5. For \"VPN Configuration File\", copy and paste the following:\n$VpnCertificateDestinationFilePath\n"
printf "6. Choose \"Add Profile\"\n"
printf "7. In the \"AWS VPN Client\" window, ensure that your profile is selected and then choose \"Connect\"\n"
read -s -n 1 -p "Press any key to continue: "
printf "\n...continuing...\n"

printf "Testing connection to VPN...\n"
hostOutput=$(host $VpnTestHost | grep ' has address ' | wc -l)
while [ $hostOutput -ne 1 ]; do
	printf "Failed to connect to the VPN\n"
	read -s -n 1 -p "Press any key to retry: "
	printf "\n...retrying...\n"
	hostOutput=$(host $VpnTestHost | grep ' has address ' | wc -l)
done 
printf "...finished\n"

printf "**********\n...finished running $0\n"

# This TODO is left intentionally, intended for the end user
printf "\n"
printf "TODO: You are now free (and encouraged) to delete this file as it's been copied to the appropriate location:\n$vpnCertificatePath\n\n"