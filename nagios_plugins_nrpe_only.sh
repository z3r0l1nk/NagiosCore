#!/bin/bash
# Nagios Core 4.0.5 Install on Debian Wheezy
# Author: John McCarthy
# <http://www.midactstech.blogspot.com> <https://www.github.com/Midacts>
# Date: 23rd of May, 2014
# Version 1.2
#
# To God only wise, be glory through Jesus Christ forever. Amen.
# Romans 16:27, I Corinthians 15:1-4
#------------------------------------------------------
######## VARIABLES ########
nagios_version=4.4.5
plugin_version=2.3.1
nrpe_version=3.2.1
######## FUNCTIONS ########
function nagiosCore()
{
	#Add Nagios Users and Groups
		echo
		echo -e '\e[01;34m+++ Adding Nagios Users and Groups...\e[0m'
		echo
		mkdir /usr/local/nagios
		groupadd -g 9000 nagios
		groupadd -g 9001 nagcmd
		useradd -u 9000 -g nagios -G nagcmd -d /usr/local/nagios -c 'Nagios Admin' nagios
		adduser www-data nagios
		chown -R nagios:nagios /usr/local/nagios
		mkdir -p /usr_local/nagios/var/rw
		chown nagios:nagios /usr_local/nagios/var
		chown nagios:www-data /usr_local/nagios/var/rw
		adduser www-data nagcmd
		echo
		echo -e '\e[01;37;42mThe Nagios users and groups have been successfully added!\e[0m'

function nagiosPlugin()
{
	#Install Require Packages
		echo
		echo -e '\e[01;34m+++ Installing Prerequisite Packages...\e[0m'
		echo
		apt-get update
		apt-get install -y libsnmp libsnmp-dev apt install build-essential libssl-dev unzip gcc make snmp snmpd net-tools dnsutils gnutls-bin libgnutls.*-dev libsnmp-dev fping nagios-plugins-contrib
		#
		# To use the check_snmp, MIBS need to be downloaded and installed.
		# install package snmp-mibs-downloader manually from non-free repo
		#
	#Download the Latest Nagios Plugin Files
		echo
        	echo -e '\e[01;34m+++ Downloading the Nagios Plugin Files...\e[0m'
		echo
        	wget https://www.nagios-plugins.org/download/nagios-plugins-$plugin_version.tar.gz
		echo -e '\e[01;37;42mThe Latest Nagios Plugins have been acquired!\e[0m'

	#Untarring the Nagios Plugin File
		echo
		echo -e '\e[01;34m+++ Untarrring the Nagios plugin files...\e[0m'
		tar xzf nagios-plugins-$plugin_version.tar.gz
		cd nagios-plugins-$plugin_version
		echo
		echo -e '\e[01;37;42mThe Nagios plugin files were successfully untarred!\e[0m'

	#Configure and Install Nagios Plugins
		echo
		echo -e '\e[01;34m+++ Installing Nagios Plugins...\e[0m'
		echo
		./configure --with-nagios-user=nagios --with-nagios-group=nagios --with-openssl=/usr/bin/openssl --enable-perl-modules --enable-libtap
		make
		make install
		echo
		echo -e '\e[01;37;42mThe Nagios Plugins have been successfully installed!\e[0m'
}
function nrpe()
{
	#Download latest NRPE Files
		echo
		echo -e '\e[01;34m+++ Downloading the Latest NRPE files...\e[0m'
		echo
		wget http://sourceforge.net/projects/nagios/files/nrpe-$nrpe_version.tar.gz

		echo -e '\e[01;37;42mThe NRPE installation files were successfully downloaded!\e[0m'

	#Untarring the NRPE File
		echo
		echo -e '\e[01;34m+++ Untarrring the NRPE files...\e[0m'
		tar xzf nrpe-$nrpe_version.tar.gz
		cd nrpe-$nrpe_version
		echo
		echo -e '\e[01;37;42mThe NRPE installation files were successfully untarred!\e[0m'

	#Configure and Install NRPE
	#http://askubuntu.com/questions/133184/nagios-nrpe-installation-errorconfigure-error-cannot-find-ssl-libraries
		echo
		echo -e '\e[01;34m+++ Installing NRPE...\e[0m'
		echo
		./configure --with-ssl=/usr/bin/openssl --with-ssl-lib=/usr/lib/arm-linux-gnueabihf
		make all
		make install
		make install-plugin
		make install-daemon
		make install-config
		make install-init
		
	# Copy NRPE Init Script and Make It Executable
	#	cp init-script.debian /etc/init.d/nrpe
	#	chmod 700 /etc/init.d/nrpe

	# Start the NRPE Daemon
		/etc/init.d/nrpe start

	# Make NRPE Start at Boot Time
	#	update-rc.d nrpe defaults
		systemctl enable nrpe.service
		echo
		echo -e '\e[01;37;42mNRPE has been successfully installed!\e[0m'
}

#This Function is Used to Call its Corresponding Function
function doAll()
{

	#Calls Function 'nagiosPlugin'
        	echo
        	echo -e "\e[33m=== Install the Nagios Plugins ? (y/n)\e[0m"
        	read yesno
        	if [ "$yesno" = "y" ]; then
                	nagiosPlugin
        	fi

	#Calls Function 'nrpe'
        	echo
        	echo -e "\e[33m=== Install NRPE ? (y/n)\e[0m"
        	read yesno
        	if [ "$yesno" = "y" ]; then
                	nrpe
        	fi

	#End of Script Congratulations, Farewell and Additional Information
		clear
		FARE=$(cat << 'EOD'


          \e[01;37;42mWell done! You have completed your Nagios Slave Installation!\e[0m
EOD
)

		#Calls the End of Script variable
		echo -e "$FARE"
		echo
		echo
        exit 0
}

# Check privileges
[ $(whoami) == "root" ] || die "You need to run this script as root."

# Welcome to the script
clear
echo
echo
echo -e '              \e[01;37;42mWelcome to Midacts Mystery'\''s Nagios Core Installer!\e[0m'
echo
echo
case "$go" in
        plugin)
                nagiosPlugin ;;
        nrpe)
                nrpe ;;
        * )
                doAll ;;
esac

exit 0
