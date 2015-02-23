# Install Docker
execute "install_docker" do
  user "root"
  command "curl -sSL https://get.docker.com/ubuntu/ | sh"
end
if node[:opsworks][:instance][:hostname] =~ /^app.*$/
  # If found an older Docker container, stop and remove the old container
  script "stop_remove_old_docker_container" do
    interpreter "bash"
    user "root"
    code <<-EOH
      docker stop #{node[:appname]}
      docker rm #{node[:appname]}
    EOH
    only_if "docker ps -a | grep #{node[:appname]}"
  end
  # Pull the Docker image from Docker image registry
  execute "pull_docker_image" do
    user "root"
    command "docker pull #{node[:dockerimage]}"
  end
  # Spawn Docker container from Image containing new app version
  execute "spawn_docker_container" do
    user "root"
    command "docker run --name #{node[:appname]} -p 8080:8080 #{node[:dockerimage]}"
  end
end
