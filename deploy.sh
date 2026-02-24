#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Check that a valid license is available
#
./validate-license.sh
if [ $? -ne 0 ]; then
  exit 1
fi

#
# Run the deployment
#
echo 'Deploying the docker compose system ...'
cd "deployments/"
docker compose --project-name fallback down 2>/dev/null
docker compose --project-name fallback up --detach
if [ $? -ne 0 ]; then
  echo 'Problem encountered running the Docker deployment'
  exit 1
fi
