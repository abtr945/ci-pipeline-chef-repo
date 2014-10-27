# setup.rb
#
# Author: An Binh Tran
#
# Set up a Docker environment for Jenkins & Docker CI pipeline on AWS OpsWorks.
# The environment can be for either TESTING or PRODUCTION.
#
# (assuming base AMI is Ubuntu)
#

# For TESTING environment (i.e. instance hostname is "test1", "test2", etc.)
if node[:opsworks][:instance][:hostname] =~ /^test.*$/

	log "testing_setup_start" do
    	message "TESTING: setup started"
    	level :info
  	end

	# Install curl
	package "curl" do
		action :install
	end

	# Install Docker
	execute "install_docker" do
		user "root"
		command "curl -sSL https://get.docker.com/ubuntu/ | sh"
	end

	# Give non-root access to Docker
	execute "give_docker_non_root_access" do
		user "root"
		command "gpasswd -a ubuntu docker"
	end

	log "testing_setup_complete" do
    	message "TESTING: setup completed"
    	level :info
  	end

# For PRODUCTION environment (i.e. instance hostname is "prod1", "prod2", etc.)
else

	log "production_setup_start" do
    	message "PRODUCTION: setup started"
    	level :info
  	end

	# Install curl
	package "curl" do
		action :install
	end

	# Install Docker
	execute "install_docker" do
		user "root"
		command "curl -sSL https://get.docker.com/ubuntu/ | sh"
	end

	# Give non-root access to Docker
	execute "give_docker_non_root_access" do
		user "root"
		command "gpasswd -a ubuntu docker"
	end
	
	log "production_setup_complete" do
    	message "PRODUCTION: setup completed"
    	level :info
  	end

end