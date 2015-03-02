#
# Cookbook Name:: POD_Toolsuite
# Recipe:: deploy
#
# Copyright 2015, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

service "docker" do
	supports :status => true
	action :start
end

# For logging purposes, output the value of jobname and dockerimage
log "log_attributes" do
	message "job_name: #{node[:jenkins][:jobname]}; docker_image: #{node[:jenkins][:dockerimage]}"
	level :info
end

script "stop_remove_old_docker_container" do
	interpreter "bash"
	user "root"
	code <<-EOH
	docker stop #{node[:jenkins][:jobname]}
	docker rm #{node[:jenkins][:jobname]}
	EOH
	only_if "docker ps -a | grep #{node[:jenkins][:jobname]}"
end

execute "pull_docker_image" do
	user "root"
	command "docker pull #{node[:jenkins][:dockerimage]}"
end

execute "spawn_docker_container_production" do
	user "root"
	command "docker run --name #{node[:jenkins][:jobname]} -p 8080:8080 #{node[:jenkins][:dockerimage]}"
end
