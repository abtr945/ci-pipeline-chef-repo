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

# If value of "jobname" attribute is a Dummy one, do not do anything (since it means the recipe is being executed at setup phase)
# "jobname" and "dockerimage" attributes are supposed to be overriden when this recipe is triggered manually
if node[:jenkins][:jobname] == "__DUMMY_JOB_NAME__"

	log "run_at_env_setup_phase" do
		message "Deploy recipe is currently running in Environment Setup phase, don't do anything..."
		level :info
	end

else

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

results = "/tmp/output.txt"
file results do
    action :delete
end

	# For TESTING environment:
	if node[:opsworks][:instance][:hostname] =~ /^test.*$/

		# If testing environment triggered by COMMIT BUILD (i.e. test-short)
		if node[:opsworks][:instance][:hostname] =~ /^test-short.*$/
	
			# Spawn a Docker container to test the Application (short tests only)
			log "spawn_container_testing_short_log" do
				message "TESTING: Spawn new Docker container for testing the Application (short tests only)"
				level :info
			end

			execute "spawn_docker_container_testing_short" do
				user "root"
				command "docker run --name #{node[:jenkins][:jobname]} #{node[:jenkins][:dockerimage]} sh -c '/opt/tomcat7/bin/startup.sh && sleep 20 && /usr/bin/ruby /project/dockertests/short_test_suite.rb'> #{results}"
			end
		
		# Else, testing environment triggered by PERIODIC BUILD (i.e. test-full)
		else
	
			# Spawn a Docker container to test the Application (full test suite)
			log "spawn_container_testing_full_log" do
				message "TESTING: Spawn new Docker container for testing the Application (full test suite)"
				level :info
			end

			execute "spawn_docker_container_testing_full" do
				user "root"
				command "docker run --name #{node[:jenkins][:jobname]} #{node[:jenkins][:dockerimage]} sh -c '/opt/tomcat7/bin/startup.sh && sleep 20 && /usr/bin/ruby /project/dockertests/short_test_suite.rb ; /usr/bin/ruby /project/dockertests/long_test_suite.rb'> #{results}"
			end

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
			command "docker run --name #{node[:jenkins][:jobname]} -p 8080:8080 #{node[:jenkins][:dockerimage]} &> #{results}"
			#command "docker run --name #{node[:jenkins][:jobname]} -p 8080:8080 #{node[:jenkins][:dockerimage]} sh -c 'exit 1'"
		end

	end
	
	ruby_block "Results" do
    only_if { ::File.exists?(results) }
    block do
        print "\n"
        File.open(results).each do |line|
            print line
        end
    end
end
	
end
