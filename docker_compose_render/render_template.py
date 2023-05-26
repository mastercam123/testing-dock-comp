#!/usr/bin/python

#####################
# This script render the docker compose file to build container images
#####################

import os
from jinja2 import Environment, FileSystemLoader

directory = "../"
filename = "docker-compose-render.yml"
file_path = os.path.join(directory, filename)

#Load Jinja2 template
env = Environment(loader = FileSystemLoader('./'), trim_blocks=True, lstrip_blocks=True)
template = env.get_template('template.j2')

#Render template using data and print the output
output_from_parsed_template = template.render(env=os.environ)
print(output_from_parsed_template)

# Save the results as a docker-compose file
with open(file_path, "w") as wr:
    wr.write(output_from_parsed_template)