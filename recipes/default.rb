#
# Cookbook Name:: simpleDeploy
# Recipe:: default
#
# Author: Kelso (Agnostos|Slygain)
# Script Assumes that ruby version is 2.0.0 or better
# Copyright (c) 2015 The Authors, All Rights Reserved.


#useful variables:
appURL = 'git://github.com/tnh/simple-sinatra-app.git'

#install required packages
package 'ruby'
package 'rdoc' #otherwise gem install fails
package 'git'


#install gem
# grab latest copy off github
git '/tmp/rubyGem' do
  repository 'git://github.com/rubygems/rubygems.git'
  revision 'master'
  action :checkout
end

# run the gem installer
execute 'gemInstall' do
  command 'ruby /tmp/rubyGem/setup.rb'
  ignore_failure true
end

#install sinatra
gem_package 'sinatra' do
  action :install
end

#get current copy of sinatra application
git '/tmp/rubyGem' do
  repository 'git://github.com/rubygems/rubygems.git'
  revision 'master'
  action :checkout
end

#deploy copy of sinatra application

#clean up any install files from sinatra application

# lockdown server



