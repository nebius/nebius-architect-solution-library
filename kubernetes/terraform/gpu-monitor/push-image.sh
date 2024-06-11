#!/bin/bash

while getopts t:d: flag
do
    case "${flag}" in
        t) tag=${OPTARG};;
        d) dockerfile=${OPTARG};;
    esac
done

if [ -z "$tag" ] || [ -z "$dockerfile" ]; then
    echo "usage: ${0} -t <docker_image_tag> -d <path_to_dockerfile>" >&2
    exit 1
fi

# https://console.nebius.ai/folders/bjef05jvuvmaf2mmuckr/container-registry/registries/crnonjecps8pifr7am4i/overview
container_registry_id=crnonjecps8pifr7am4i

docker build --tag "${tag}" --platform=linux/amd64 -f "${dockerfile}" .
docker tag "${tag}" cr.nemax.nebius.cloud/"${container_registry_id}"/"${tag}"
docker push cr.nemax.nebius.cloud/"${container_registry_id}"/"${tag}"å