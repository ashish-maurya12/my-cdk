#getting base image ubuntu
FROM ubuntu:20.04
LABEL owner="sharmanand.sharma1@rsystems.com"
#installing software and updating it
RUN apt-get update -y 
RUN apt-get install software-properties-common -y
RUN add-apt-repository ppa:ondrej/php -y
RUN apt-get install php7.2 libapache2-mod-php7.2 php7.2-common php7.2-curl php7.2-mbstring php7.2-xmlrpc php7.2-mysql php7.2-gd php7.2-xml php7.2-intl php7.2-ldap php7.2-imagick php7.2-json php7.2-cli  -y
RUN apt-get install supervisor -y
RUN apt-get install curl -y
RUN apt-get install git -y
RUN apt-get update -y
RUN mkdir -p /var/www/html/admin

#Downloading laravel project i.e inovcare.com from git

RUN git clone -b development --single-branch https://gitlab_2112:Welcome2gitlab2022@gitlab.com/erginous/inovcares_web-p2.git /var/www/html/admin/

#Downloading wordpress project i.e main.inovcare.com from git
RUN mkdir -p /var/www/html/main
RUN git clone -b development --single-branch https://gitlab_2112:Welcome2gitlab2022@gitlab.com/erginous/inovcares_wp_2022.git /var/www/html/main/

#setting permissions for project folder
#echo "giving permission to  project folder";

RUN chown -R www-data:www-data /var/www/html/admin/ && chmod -R 777 /var/www/html/admin/ && chmod -R 777 /var/www/html/admin/storage

#setting permissions for project folder
#echo "giving permission to  project main folder";
RUN chown -R www-data:www-data /var/www/html/main/ && chmod -R 777 /var/www/html/main/
#RUN sudo chmod -R 777 /var/www/html/main/wp-content

#getting base image ubuntu
#Installing composer
#echo "Installing composer packages for Project";
RUN curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
RUN HASH=`curl -sS https://composer.github.io/installer.sig`
RUN Verify=`php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"`
RUN $Verify
RUN php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
#Installing zip unzip for $composer install
RUN apt install zip unzip php7.2-zip -y

#Installing laravel project suppotive packages using composer
RUN composer update --working-dir=/var/www/html/admin --no-scripts
RUN com=`composer install --working-dir=/var/www/html/admin`
RUN $com
#RUN <em>Yes .....</em> 
# Downloading secrets from git
#echo "Downloading secrets & ssl";
RUN git clone -b credentials --single-branch https://gitlab_2112:Welcome2gitlab2022@gitlab.com/erginous/inovweb_2022.git

#echo "moving .env to project folder";
RUN mv inovweb_2022/.env /var/www/html/admin/

#echo "moving 000-default.conf to apache2/sites-available";
RUN  mv inovweb_2022/000-default.conf /etc/apache2/sites-available/

#echo "moving default-ssl.conf to apache2/sites-available";
RUN  mv inovweb_2022/default-ssl.conf /etc/apache2/sites-available/

#echo "moving key to /etc/ssl/private/";
RUN  mv inovweb_2022/inovcares.com.key /etc/ssl/private/

RUN  mkdir /etc/ssl/20211101/

#echo "moving key to /etc/ssl/20211101/";
RUN  mv inovweb_2022/ce62ecce920e2923.crt /etc/ssl/20211101/

#echo "moving key to /etc/ssl/20211101/";
RUN  mv inovweb_2022/gd_bundle-g2-g1.crt /etc/ssl/20211101/

#echo "entering into project folder";
RUN cd /var/www/html/admin/
WORKDIR /var/www/html/admin/

#echo "removing vendor folder";
RUN rm -R vendor
RUN composer update

# Adding rewriting engine to system
RUN  a2enmod rewrite

#restarting apache
CMD ["apachectl", "-D", "FOREGROUND"]
