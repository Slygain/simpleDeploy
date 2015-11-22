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

#install required packages
package 'ruby'
package 'git'
# needed to allow us to install nginx & Phusion
package 'epel-release'

#add passenger repository
execute 'Phusion addition' do
  command 'curl --fail -sSLo /etc/yum.repos.d/passenger.repo https://oss-binaries.phusionpassenger.com/yum/definitions/el-passenger.repo'
end

# finish with package manipulation
package 'nginx'
package 'passenger'

# work out how to manipulate /etc/nginx/conf.d/passenger.conf - uncomment 3 lines


#setup services related to nginx
service 'nginx' do 
  action [ :enable, :start ]
end

#install sinatra
gem_package 'sinatra' do
  action :install
end

#install bundler
gem_package 'bundler' do
  action :install
end

#get copy of sinatra application
git '/tmp/sinatraApp' do
  repository 'git://github.com/tnh/simple-sinatra-app.git'
  revision 'master'
  action :checkout
end
# Move out application somewhere more sane
execute "create sinatraApp Directory" do
    command "mkdir -p ~/apps"
    user "root"
end
execute "copy sinatraApp" do
    command "cp -rf /tmp/sinatraApp ~/apps/sinatraApp"
    user "root"
end
 
#install bundle from sinatra application
execute 'bundle install' do
  cwd '/root/apps/sinatraApp'
  command 'bundle install'
end

# write over the top of the nginx configuration file
#TODO: shift to template.
file '/etc/nginx/nginx.conf' do
  content '
worker_processes  1;
events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;
    
    server {
        listen 80;
        server_name _;
        root /root/apps/sinatraApp/public;
        passenger_enabled on;

        # redirect server error pages to the static page /50x.html
        error_page   500 502 503 504  /50x.html;
        location = /50x.html {
            root   html;
        }
    }
}'
end

#reload nginx 
execute "reload Nginx" do
    command "service nginx restart"
    user "root"
end

# add these rules to the firewall so that it's extnerally accessible
#sudo firewall-cmd --permanent --zone=public --add-service=http 
#sudo firewall-cmd --permanent --zone=public --add-service=https
#sudo firewall-cmd --reload



