#
# Cookbook Name:: POD_Toolsuite
# Recipe:: bootstrap
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

package "curl" do
	action :install
end

execute "install_docker" do
	user "root"
	command "curl -sSL https://get.docker.com/ubuntu/ | sh"
end
