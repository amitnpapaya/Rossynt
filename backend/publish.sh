#!/usr/bin/env bash

TARGET_PATH=../plugin/src/main/resources/raw/RossyntBackend
IMAGE_NAME=temp-publish-rossynt-backend
FILE_LIST_FILE_NAME=FileList.txt
CONTAINER_NAME=temp-publish-rossynt-backend-container

# Clean target path.
rm -rf "${TARGET_PATH}"

# Build in Docker.
docker build --tag "${IMAGE_NAME}" . || exit $?

# Copy artifacts to target path.
mkdir -p "${TARGET_PATH}"

docker container rm "${CONTAINER_NAME}" || true
docker container create --name "${CONTAINER_NAME}" "${IMAGE_NAME}" || exit $?
docker container cp "${CONTAINER_NAME}":/app/. "${TARGET_PATH}" || exit $?
docker container rm "${CONTAINER_NAME}" || exit $?

# Delete the executables (we only need the DLLs).
rm -v "${TARGET_PATH}"/*/RossyntBackend

# Generate file lists.
for DIRECTORY in "${TARGET_PATH}"/* ; do
    pushd "${DIRECTORY}"
    find . -type f | grep -v -F "./${FILE_LIST_FILE_NAME}" > "${FILE_LIST_FILE_NAME}"
    popd
done
