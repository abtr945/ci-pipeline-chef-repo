# env_setup_prod.rb
#
# Author: An Binh Tran
#
# Set up a Production environment for Jenkins & Docker CI pipeline on AWS OpsWorks
# (assuming base AMI is Ubuntu)
#

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

service "docker" do
	action :restart
end
