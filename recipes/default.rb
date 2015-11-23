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

#add passenger repository
execute 'Phusion addition' do
  command 'curl --fail -sSLo /etc/yum.repos.d/passenger.repo https://oss-binaries.phusionpassenger.com/yum/definitions/el-passenger.repo'
end

# work around for having a new repository and needing it to accept the gpg key
execute 'manual Ruby Install' do
  command 'yum install ruby -y'
end

#install required packages
package 'git'
# needed to allow us to install nginx & Phusion
package 'epel-release'
package 'nginx'
package 'passenger'


# work out how to manipulate /etc/nginx/conf.d/passenger.conf - uncomment 3 lines
# TODO: May not need to do this afterall

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
# grabs the passenger broadcast from port 3000 and pushes it across to port 80
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
        server_name localhost;
        
        location ~ \ {
        proxy_pass http://127.0.0.1:3000;
        }

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

#create a service for our passenger
file '/usr/lib/systemd/system/sinatraApp.service' do
    content'
    [Unit]
Description=The sinatraApplication
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/passenger start -d ~/apps/sinatraApp
ExecReload=/usr/bin/passenger stop; /usr/bin/passenger start -d ~/apps/sinatraApp
KillMode=process
# Sleep for 1 second to give PassengerAgent a chance to clean up.
ExecStop=passenger stop; /bin/sleep 1
PrivateTmp=true

[Install]
WantedBy=multi-user.target

    '
end

# setup passenger service
service "sinatraApp" do
    action [ :enable, :start ]
end

# allows port 80 to be accessible externally
execute "add firewall rules" do
command 'firewall-cmd --permanent --zone=public --add-service=http ;firewall-cmd --permanent --zone=public --add-service=https;firewall-cmd --reload '
end



