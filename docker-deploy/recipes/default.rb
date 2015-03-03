#
# Cookbook Name:: docker-deploy
# Recipe:: default
#
# Copyright 2015, An Binh Tran
#
# All rights reserved - Do Not Redistribute
#

# Install curl
package "curl" do
	action :install
end

# Install docker if not already installed
execute "install_docker" do
	user "root"
	command "curl -sSL https://get.docker.com/ubuntu/ | sh"
	not_if "dpkg-query -W docker"
end

# Start docker daemon if not already started
service "docker" do
	supports :status => true
	action :start
end

# Check for provided attributes: Jenkins Job name and Docker Image URL
if (node[:jenkins][:jobname] == "") or (node[:jenkins][:dockerimage] == "")

	# Deployment will fail if attributes not provided
	Chef::Application.fatal!("Jenkins Job name and/or Docker Image URL not provided!", 1)

else

	# Stop and remove existing Docker container with older app version
	script "stop_remove_old_docker_container" do
		interpreter "bash"
		user "root"
		code <<-EOH
		docker stop #{node[:jenkins][:jobname]}
		docker rm #{node[:jenkins][:jobname]}
		EOH
		only_if "docker ps -a | grep #{node[:jenkins][:jobname]}"
	end

	# Pull new version of Docker image
	execute "pull_docker_image" do
		user "root"
		command "docker pull #{node[:jenkins][:dockerimage]}"
	end

	# Spawn new Docker container with newer app version from new image
	execute "spawn_docker_container_from_new_image" do
		user "root"
		command "docker run --name #{node[:jenkins][:jobname]} -p 8080:8080 #{node[:jenkins][:dockerimage]}"
	end

end
