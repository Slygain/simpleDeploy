#
# Cookbook Name:: simpleDeploy
# Recipe:: default
#
# Author: Kelso (Agnostos|Slygain)
#
# Copyright (c) 2015 The Authors, All Rights Reserved.


#useful variables:
appURL = 'git://github.com/tnh/simple-sinatra-app.git'

#install required packages
package 'ruby'
package 'git'

#install gem
# Note: There is copy of gem in chef, however it relies on the copy of ruby and gem included with chef. 
# We'll grab the latest version from github

# grab latest copy off github

git '/tmp/rubyGem' do
  repository 'git://github.com/rubygems/rubygems.git'
  revision 'master'
  action :checkout
end
# run the gem installer
execute 'gemInstall' do
  command 'ruby /tmp/rubyGem/setup.rb'
  ignore_failure
end


#install sinatra

#check if sinatra installed (TODO: Remove me)

#get current copy of sinatra application

#deploy copy of sinatra application

#clean up any install files from sinatra application

# lockdown server



