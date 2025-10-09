#!/bin/bash

#############################################################################################################
# Builds a custom container of the Curity Identity Server that includes the service-checker 
# authentication action plugin.
#############################################################################################################

#
# Ensure that we are in the folder containing this script
#
cd "$(dirname "${BASH_SOURCE[0]}")"

#
# This is for Curity developers only
#
cp ./hooks/pre-commit .git/hooks

#
# Build the custom Docker image of the Curity Identity Server that contains the service checker plugin
#
cd deployments/idsvr

git clone https://github.com/Curity-PS/service-status-checker
cd service-status-checker
./gradlew jar

if [ $? -ne 0 ]; then
  echo "Problem encountered building the custom service checker plugin"
  exit 1
fi
cd ..

docker build -f Dockerfile -t custom/idsvr:1.0 .
if [ $? -ne 0 ]; then
  echo "Problem encountered building the custom Curity Docker file"
  exit 1
fi
cd ..

rm -rfv ./idsvr/service-status-checker/
if [ $? -ne 0 ]; then
  echo 'Problem encountered building deployment resources'
  exit
fi
