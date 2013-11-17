#install MySQL Server, PHP, and Apache so WordPress has it’s requirements


#Unfortunately, the package for MySQL prompts you for a password and we want this to be a completely hands off experience. 
#The first two lines in the commands below set the password for installing MySQL
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password rootpass'
sudo debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password rootpass'

#This line updates apt-get’s list of packages (you can run into “missing” packages if you skip this step), and the fourth line installs everything we need.
sudo apt-get update
sudo apt-get -y install mysql-server-5.5 php-pear php5-mysql apache2 php5

#Creating the database settings
#user name = root
#password = rootpass
if [ ! -f /var/log/databasesetup ];
then
	echo "CREATE USER 'wordpressuser'@'localhost' IDENTIFIED BY 'wordpresspass'" | mysql -uroot -prootpass
	echo "CREATE DATABASE wordpress" | mysql -uroot -prootpass
	echo "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost'" | mysql -uroot -prootpass
	echo "flush privileges" | mysql -uroot -prootpass

	# Because this script will run every time the VM boots we need to make sure that the process for creating the database and the database user will only run once. 
	# To do this we touch a file name /var/log/databasesetup and if the file exists we skip over this part. 
	# The section at the very bottom checks to see if there is an initial data file and restores it to the database.
	touch /var/log/databasesetup

	if [ -f /vagrant/data/initial.sql ];
	then
		mysql -uroot -prootpass wordpress < /vagrant/data/initial.sql
	fi
fi

#'Configure Apache'
if [ ! -h /var/www ];
then 
	rm -rf /var/www
	sudo ln -s /vagrant/public /var/www

	a2enmod rewrite

	sed -i '/AllowOverride None/c AllowOverride All' /etc/apache2/sites-available/default

	service apache2 restart
	#To create a directory outside of the public or home directory you will need to use the 'sudo' command
	# i.e. sudo mkdir /var/log/<DirName>
	# to then create a file: sudo touch /var/log/openvpn/openvpn-status.log
fi

# This will make a backup copy of our WordPress database so we can easily restore it the next time we recreate the VM. 
# mkdir /vagrant/data mysqldump -uroot -prootpass wordpress > /vagrant/data/initial.sql
