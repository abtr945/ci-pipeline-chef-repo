# prod_start_update.rb
#
# Author: An Binh Tran
#
# Start a Production environment for the application, or update a current Environment
#

# Define a check whether a Docker container with the same name as Jenkins JobName is currently running
# Return TRUE if found, FALSE otherwise
execute "old_docker_container_found" do
	user "root"
	command "docker ps -a | grep node[:jenkins][:jobname]"
	action :nothing
end

# If found an older Docker container, stop and remove the old container
script "stop_remove_old_docker_container" do
	interpreter "bash"
	user "root"
	code <<-EOH
		docker stop node[:jenkins][:jobname]
		docker rm node[:jenkins][:jobname]
	EOH
	only_if "old_docker_container_found"
end

# Pull the Docker image corresponding to the given Jenkins JobName and BuildNumber
# from the given Docker registry host:port
execute "pull_docker_image" do
	user "root"
	command "docker pull node[:registry][:host]:node[:registry][:port]/node[:jenkins][:jobname]:node[:jenkins][:buildnumber]"
end

# Spawn a Docker container whose name is the name of the Jenkins JobName
execute "spawn_docker_container" do
	user "root"
	command "docker run --name node[:jenkins][:jobname] node[:registry][:host]:node[:registry][:port]/node[:jenkins][:jobname]:node[:jenkins][:buildnumber]"
end
