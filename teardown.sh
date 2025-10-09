#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

#
# Tear down deployed components
#
docker compose --project-name fallback down
docker volume remove fallback_ldap-config
docker volume remove fallback_ldap-data
