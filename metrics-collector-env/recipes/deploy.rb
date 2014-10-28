# deploy.rb
#
# Author: An Binh Tran
#
# Deploy Docker container of the application on the Opsworks Environment.
#
# The purpose of the container can be for running tests (in TESTING environment),
# or for PRODUCTION purposes.
#

# For logging purposes, output the value of jobname and dockerimage
log "log_attributes" do
	message "job_name: #{node[:jenkins][:jobname]}; docker_image: #{node[:jenkins][:dockerimage]}"
    level :info
end


# If found an older Docker container, stop and remove the old container
log "remove_old_container_log" do
	message "COMMON: Remove any old Docker container"
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


# Pull the Docker image from an image registry.
#
# The Docker image format: <registry_host>:<registry_port>/<image_name>:<image_version>
# For example: 54.253.116.128:5000/metrics-collector-periodic-build:100
log "pull_docker_image_log" do
	message "COMMON: Pull new Docker image from external registry"
    level :info
end

execute "pull_docker_image" do
	user "root"
	command "docker pull #{node[:jenkins][:dockerimage]}"
end


# For TESTING environment:
if node[:opsworks][:instance][:hostname] =~ /^test.*$/

	# Spawn a Docker container to test the Application
	log "spawn_container_testing_log" do
		message "TESTING: Spawn new Docker container for testing the Application"
    	level :info
	end

	execute "spawn_docker_container_testing" do
		user "root"
		command "docker run --name #{node[:jenkins][:jobname]} #{node[:jenkins][:dockerimage]}"
	end

	
# For PRODUCTION environment:	
else

	# Spawn a Docker container to run the Application, and expose the Container Port 8080 to the outside host
	log "spawn_container_production_log" do
		message "PRODUCTION: Spawn new Docker container for running the Application"
    	level :info
	end
	
	execute "spawn_docker_container_production" do
		user "root"
		command "docker run --name #{node[:jenkins][:jobname]} -p 8080:8080 #{node[:jenkins][:dockerimage]} &"
	end

end