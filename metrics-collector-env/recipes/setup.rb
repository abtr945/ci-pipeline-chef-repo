# setup.rb
#
# Author: An Binh Tran
#
# Set up a Docker environment for Jenkins & Docker CI pipeline on AWS OpsWorks.
# The environment can be for either TESTING or PRODUCTION.
#
# (assuming base AMI is Ubuntu)
#

# COMMON setup process - for both testing and production environments

# Install curl
log "install_curl_log" do
    message "COMMON: install curl"
    level :info
end

package "curl" do
	action :install
end


# Install Docker
log "install_docker_log" do
    message "COMMON: install docker"
    level :info
end

execute "install_docker" do
	user "root"
	command "curl -sSL https://get.docker.com/ubuntu/ | sh"
end


# Give non-root access to Docker
log "give_docker_non_root_access_log" do
    message "COMMON: give non-root access to Docker"
    level :info
end

execute "give_docker_non_root_access" do
	user "root"
	command "gpasswd -a ubuntu docker"
end


# Setup process exclusively for TESTING environment (i.e. instance hostname is "test1", "test2", etc.)
if node[:opsworks][:instance][:hostname] =~ /^test.*$/

	log "testing_setup_start" do
    	message "TESTING: additional setup"
    	level :info
  	end

	# TODO add any TESTING-exclusive setup here

# Setup process exclusively for PRODUCTION environment (i.e. instance hostname is "prod1", "prod2", etc.)
else

	log "production_setup_start" do
    	message "PRODUCTION: additional setup"
    	level :info
  	end

	# TODO add any PRODUCTION-exclusive setup here

end