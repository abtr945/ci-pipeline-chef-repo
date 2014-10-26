# Dummy values for attributes.
# Will be overriden by custom JSON each time the recipe is run

default[:jenkins][:jobname] = "dummy-job-name"
default[:jenkins][:dockerimage] = "dummy-docker-registry-host:5000/dummy-docker-image:latest"
