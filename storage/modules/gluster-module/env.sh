#/bin/sh
export NCP_TOKEN=$(ncp iam create-token)
export NCP_CLOUD_ID=$(ncp config get cloud-id)
export NCP_FOLDER_ID=$(ncp config get folder-id)