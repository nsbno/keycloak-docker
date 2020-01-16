#!/usr/bin/env bash
set -e

. "$NSB_SCRIPT_DIR/lib/input.sh"
. "$NSB_SCRIPT_DIR/lib/output.sh"

SERVICE_ACCOUNT="592256481107"
ECR_ENDPOINT="${SERVICE_ACCOUNT}.dkr.ecr.eu-west-1.amazonaws.com"
REPOSITORY_NAME="keycloak-base"
IMAGE_NAME="${ECR_ENDPOINT}/${REPOSITORY_NAME}"
REGION="eu-west-1"

if [ "x$(aws sts get-caller-identity 2>/dev/null | jq -r ".Account")" != "x$SERVICE_ACCOUNT" ]; then
  error "You are missing valid API credentials for the service account. Please make sure you are logged in."
  exit -1
fi

$(aws ecr get-login --region "${REGION}" --no-include-email)

keycloak_version=$(grep -E "ENV KEYCLOAK_VERSION=[0-9]+(\.[0-9]+)?.*" Docker/Dockerfile | sed 's/.*VERSION=\([0-9\.]*\).*/\1/')
prev_version=$(aws ecr describe-images --region ${REGION} --repository-name ${REPOSITORY_NAME} | jq -r ".imageDetails[].imageTags[]" | grep "${keycloak_version}" | awk -F- '{print $NF}' | sort -rn | head -1)
version="${keycloak_version}-$((${prev_version:-0} + 1))"

info "Releasing version ${version}"

docker build -t "${IMAGE_NAME}" Docker/
docker tag "${IMAGE_NAME}" "${IMAGE_NAME}:${version}"
docker push "${IMAGE_NAME}:${version}"
docker tag "${IMAGE_NAME}" "${IMAGE_NAME}:latest"
docker push "${IMAGE_NAME}:latest"
