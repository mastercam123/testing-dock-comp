#!/bin/bash
set -e

ECR_URL="${ECR_URL:=}"
COMPANY_IDENTIFIER="${COMPANY_IDENTIFIER:=}"
VMON_SERVER_VERSION="${VMON_SERVER_VERSION:=}"
APPLICATION_NAME="${APPLICATION_NAME:=}"

if [[ -z $APPLICATION_NAME ]]; then
  echo "expected env APPLICATION_NAME to be set but was empty"
  exit 1
fi

if [[ -z $COMPANY_IDENTIFIER ]]; then
  echo "expected env COMPANY_IDENTIFIER to be set but was empty"
  exit 1
fi

if [[ -z $ECR_URL ]]; then
  echo "expected env ECR_URL to be set but was empty"
  exit 1
fi

if [[ -z $VMON_SERVER_VERSION ]]; then
  echo "expected env VMON_SERVER_VERSION to be set but was empty"
  exit 1
fi

echo "The version is: $VMON_SERVER_VERSION"

# Render a docker-compose
cd docker_compose_render/
python3 render_template.py

cd ..

echo "building container image..."
docker compose -f docker-compose-render.yml build --no-cache

echo "pushing container image to shared ECR..."
docker compose -f docker-compose-render.yml push 
