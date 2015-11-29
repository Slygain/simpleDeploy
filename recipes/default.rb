#
# Cookbook Name:: simpleDeploy
# Recipe:: default
#
# Author: Kelso (Agnostos|Slygain)
# 
# Copyright (c) 2015 The Authors, All Rights Reserved.
#
# improvements that can be made:
# setup variables with known file locations so recipe can re-used for other applications
# Currently assumes user is root

#initial required yum packages
package 'ruby'
package 'git'
package 'httpd'

#pasenger requirements
package 'gcc'
package 'gcc-c++'
package 'zlib-devel'
package 'libcurl-devel'
package 'httpd-devel'
package 'ruby-devel'
package 'apr-devel'
package 'apr-util-devel'


service 'httpd' do
  action [ :enable, :start ]
end

#gem packages required to run sinatra application
gem_package 'passenger'
gem_package 'bundler'

#run the phusion passanger apache installer in automated install mode
execute 'configure passenger' do
  command 'passenger-install-apache2-module -a'
end

#create configuration for apache (httpd)
file '/etc/httpd/conf.d/sinatra.conf' do
 content ' LoadModule passenger_module /usr/local/share/gems/gems/passenger-5.0.21/buildout/apache2/mod_passenger.so
   <IfModule mod_passenger.c>
     PassengerRoot /usr/local/share/gems/gems/passenger-5.0.21
     PassengerDefaultRuby /usr/bin/ruby
   </IfModule>
   
  <VirtualHost *:80>
    ServerName localhost
    DocumentRoot /var/www/apps/sinatraApp/public
    <Directory /var/www/apps/sinatraApp/public>
        Require all granted
        Allow from all
        Options -MultiViews
    </Directory>
</VirtualHost> 
'
end

#create apps directory
directory '/var/www/apps' do
end

git '/var/www/apps/sinatraApp' do
  repository 'git://github.com/tnh/simple-sinatra-app.git'
  revision 'master'
  action :checkout
end

execute 'bundle install' do
  cwd '/var/www/apps/sinatraApp'
  command 'bundle install'
end

#create directories that will be needed to run the sinatra Application
%w[ /var/www/apps/sinatraApp/public /var/www/apps/sinatraApp/tmp].each do |pathy|
  directory pathy do
  end
end

#create rule to allow port 80 to be accessible
execute "add firewall rules" do
command 'firewall-cmd --permanent --zone=public --add-service=http ;firewall-cmd --reload '
end

#finally restart apache to allow all the changes made to propogate
service 'httpd' do
  action [:restart]
end


