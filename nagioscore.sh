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
plugin_version=2.3.0
nrpe_version=3.2.1
######## FUNCTIONS ########
function nagiosCore()
{
	#Add Nagios Users and Groups
		echo
		echo -e '\e[01;34m+++ Adding Nagios Users and Groups...\e[0m'
		echo
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

	#Install Require Packages
		echo
		echo -e '\e[01;34m+++ Installing Prerequisite Packages...\e[0m'
		echo
		apt-get update
		apt-get install -y apache2 apache2-utils libapache2-mod-php7.3 build-essential libssl-dev unzip gcc make snmp snmpd net-tools dnsutils mariadb-server gnutls-bin libgnutls.*-dev php7.3-mysql php-ssh2 php-pear php-mysql
		phpenmod mysqli gettext
		a2enmod cgi
		echo
		echo -e '\e[01;37;42mThe Prerequisite Packages were successfully installed!\e[0m'

	#Download latest Nagios Core Version
		echo
		echo -e '\e[01;34m+++ Downloading the Latest Nagios Core files...\e[0m'
		echo
		wget http://prdownloads.sourceforge.net/sourceforge/nagios/nagios-$nagios_version.tar.gz
		echo -e '\e[01;37;42mThe Nagios Core installation files were successfully downloaded!\e[0m'

	#Untarring the Nagios Core File
		echo
		echo -e '\e[01;34m+++ Untarrring the Nagios Core files...\e[0m'
		tar xzf nagios-$nagios_version.tar.gz
		cd nagios-$nagios_version
		echo
		echo -e '\e[01;37;42mThe Nagios Core installation files were successfully untarred!\e[0m'

	#Configure and Install Nagios Core
		echo
		echo -e '\e[01;34m+++ Installing Nagios Core...\e[0m'
		echo
		./configure --prefix=/usr/local/nagios --with-nagios-user=nagios --with-nagios-group=nagios --with-command-user=nagios --with-command-group=nagcmd
		make all
		make install
		make install-init
		make install-config
		make install-commandmode
		make install-webconf
		echo -e '\e[01;37;42mNagios Core has been successfully installed!\e[0m'
}
function webUIpassword()
{
	#Create a user to access the Nagios Web UI
		echo
        	echo -e '\e[33mChoose your Nagios Web UI Username\e[0m'
		read webUser

	# Use this command to add subsequent users later on (eliminate the '-c' switch, which creates the file)
	# htpasswd /usr/local/nagios/etc/htpasswd.users username
	# **NOTE** users will only see hots/services for which they are contacts <http://nagios.sourceforge.net/docs/nagioscore/3/en/cgiauth.html>
		htpasswd -c /usr/local/nagios/etc/htpasswd.users $webUser

	#Changes the Ownership of the htpasswd.users file
		chown nagios:nagcmd /usr/local/nagios/etc/htpasswd.users
		echo
        	echo -e '\e[01;37;42mNagios Web UI Username and password successfully created!\e[0m'
}
function nagiosBoot()
{
	#Enabling nagios to start at boot time
		echo
        	echo -e '\e[01;34m+++ Enabling Nagios to Start at boot time...\e[0m'
        	echo
		update-rc.d nagios defaults

	#Restart the Nagios service
		service nagios restart
		echo
        	echo -e '\e[01;37;42mNagios has been configured to start at boot time!\e[0m'
}
function nagiosPlugin()
{
	#Install Require Packages
		echo
		echo -e '\e[01;34m+++ Installing Prerequisite Packages...\e[0m'
		echo
		apt-get update
		apt-get install -y libsnmp libsnmp-dev
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
		echo -e '\e[01;34m+++ Untarrring the Nagios Core files...\e[0m'
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
		make install-daemon-config

	# Copy NRPE Init Script and Make It Executable
		cp init-script.debian /etc/init.d/nrpe
		chmod 700 /etc/init.d/nrpe

	# Start the NRPE Daemon
		/etc/init.d/nrpe start

	# Make NRPE Start at Boot Time
		update-rc.d nrpe defaults
		echo
		echo -e '\e[01;37;42mNRPE has been successfully installed!\e[0m'
}
function emailNotifications()
{
	#Install Require Packages
		echo
		echo -e '\e[01;34m+++ Installing Prerequisite Packages...\e[0m'
		echo
		apt-get install -y sendmail-bin sendmail heirloom-mailx
		echo
		echo -e '\e[01;37;42mThe Rrerequisite Packages for Nagios Notifications were successfully installed!\e[0m'
}
function webSSL()
{
	#Make Your Self-signed Certificates
		echo
		echo -e '\e[33mChoose your Certificates Name\e[0m'
		read CERT
		mkdir /etc/apache2/ssl
		cd /etc/apache2/ssl
		openssl req -x509 -nodes -days 365 -newkey rsa:4096 -keyout $CERT.key -out $CERT.crt
		a2enmod ssl

	#Configure /etc/apache2/conf.d/nagios.conf
		sed -i 's/#  SSLRequireSSL/   SSLRequireSSL/g' /etc/apache2/conf.d/nagios.conf

	#Configure /etc/apache2/sites-available/nagios
		echo
		echo -e '\e[33mChoose your Server Admin Email Address\e[0m'
		read EMAIL
cat <<EOF > /etc/apache2/sites-available/nagios
<VirtualHost *:443>
    ServerAdmin $EMAIL
    ServerName $CERT.crt
    DocumentRoot /var/www/$CERT

    <Directory />
        Options FollowSymLinks
        AllowOverride None
    </Directory>

    <Directory /var/www/$CERT>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Order allow,deny
        allow from all
    </Directory>

     SSLEngine On
     SSLCertificateFile /etc/apache2/ssl/$CERT.crt
     SSLCertificateKeyFile /etc/apache2/ssl/$CERT.key
</VirtualHost>
EOF

	# Enable the nagios site
        	a2ensite nagios
        
	#Make DirectoryRoot Directory
		mkdir /var/www/$CERT

	#Restart Your Apache2 Service
		service apache2 restart
}

#This Function is Used to Call its Corresponding Function
function doAll()
{
    #Calls Function 'nagioscore'
		echo -e "\e[33m=== Install Nagios Core ? (y/n)\e[0m"
        	read yesno
        	if [ "$yesno" = "y" ]; then
                	nagiosCore
	        fi

	#Calls Function 'webUIpassword'
        	echo
        	echo -e "\e[33m=== Add Nagios Web UI Password ? (y/n)\e[0m"
        	read yesno
        	if [ "$yesno" = "y" ]; then
                	webUIpassword
        	fi

	#Calls Function 'nagiosBoot'
		echo
        	echo -e "\e[33m=== Start Nagios Server at Boot Time ? (y/n)\e[0m"
        	read yesno
        	if [ "$yesno" = "y" ]; then
	                nagiosBoot
	        fi

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

	#Calls Function 'emailNotifications'
        	echo
        	echo -e "\e[33m=== Edit Nagios Email Notification Settings ? (y/n)\e[0m"
        	read yesno
        	if [ "$yesno" = "y" ]; then
                	emailNotifications
	        fi

	#Calls Function 'webSSL'
		echo
        	echo -e "\e[33m=== Configure Nagios Web UI to use SSL (HTTPS) ? (y/n)\e[0m"
        	read yesno
        	if [ "$yesno" = "y" ]; then
                	webSSL
        	fi

	#End of Script Congratulations, Farewell and Additional Information
		clear
		FARE=$(cat << 'EOD'


          \e[01;37;42mWell done! You have completed your Nagios Core Installation!\e[0m

             \e[01;37;42mProceed to your Nagios web UI, http://fqdn/nagios\e[0m
  \e[30;01mCheckout similar material at midactstech.blogspot.com and github.com/Midacts\e[0m


                            \e[01;37m########################\e[0m
                            \e[01;37m#\e[0m \e[31mI Corinthians 15:1-4\e[0m \e[01;37m#\e[0m
                            \e[01;37m########################\e[0m
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
        core)
                nagiosCore ;;
        webPass)
                webUIpassword ;;
        boot)
                nagiosBoot ;;
        plugin)
                nagiosPlugin ;;
        nrpe)
                nrpe ;;
        email)
                emailNotifications ;;
        ssl)
                webSSL ;;
        * )
                doAll ;;
esac

exit 0
