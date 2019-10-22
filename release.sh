#!/bin/bash

ECR_ENDPOINT="592256481107.dkr.ecr.eu-west-1.amazonaws.com"
REGION="eu-west-1"

version=${1}

$(aws ecr get-login --region "${REGION}" --no-include-email) || echo "Unable to access AWS ECR. Make sure you have valid credentials"

docker build -t "${ECR_ENDPOINT}/keycloak-base" Docker/
docker tag "${ECR_ENDPOINT}/keycloak-base" "${ECR_ENDPOINT}/keycloak-base:7.0.0-${version}"
docker push "${ECR_ENDPOINT}/keycloak-base:7.0.0-${version}"
docker tag "${ECR_ENDPOINT}/keycloak-base" "${ECR_ENDPOINT}/keycloak-base:latest"
docker push "${ECR_ENDPOINT}/keycloak-base:latest"