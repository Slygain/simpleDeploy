#
# Cookbook Name:: simpleDeploy
# Recipe:: default
#
# Author: Kelso (Agnostos|Slygain)
# Script Assumes that ruby version is 2.0.0 or better
# Copyright (c) 2015 The Authors, All Rights Reserved.


#install required packages
package 'ruby'
package 'git'

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

#place Sinatra app in decent location

#clean up any install files from sinatra application

# lockdown server



