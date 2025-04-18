#!/bin/sh

# Update system packages
sudo apt-get update
sudo apt-get install -y python3 python3-pip
pip3 install virtualenv
python3 -m virtualenv dbt_env

# Activate the virtual environment
source dbt_env/bin/activate
pip install dbt-bigquery

# Create a directory for your project
mkdir -p ~/dbt_projects
cd ~/dbt_projects

# Initialize a new dbt project
dbt init ipl_analytics
cd ipl_analytics
mkdir -p ~/.dbt
nano ~/.dbt/profiles.yml