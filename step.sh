#!/usr/bin/env bash

# 'read' has to be before 'set -e'
read -r -d '' UNAVAILABLE_MESSAGE << EOF_MSG
Bitrise Build Cache is not activated in this build.

You have added the **Activate Bitrise Build Cache for Bazel** add-on step to your workflow.

However, you don't have an activate Bitrise Build Cache Trial or Subscription for the current workspace yet.

You can activate a Trial at [app.bitrise.io/build-cache](https://app.bitrise.io/build-cache),
or contact us at [support@bitrise.io](mailto:support@bitrise.io) to activate it.
EOF_MSG

set -eo pipefail

echo "Checking whether Bitrise Build Cache is activated for this workspace ..."
if [ "$BITRISEIO_BUILD_CACHE_ENABLED" != "true" ]; then
  printf "\n%s\n" "$UNAVAILABLE_MESSAGE"
  set -x
  bitrise plugin install https://github.com/bitrise-io/bitrise-plugins-annotations.git
  bitrise :annotations annotate "$UNAVAILABLE_MESSAGE" --style error || {
    echo "Failed to create annotation"
    exit 3
  }
  exit 2
fi
echo "Bitrise Build Cache is activated in this workspace, configuring the build environment ..."

set -x

case "${BITRISE_DEN_VM_DATACENTER}" in
LAS1)
export BITRISE_CACHE_ENDPOINT=grpc://las-cache.services.bitrise.io:6666
;;
ATL1)
export BITRISE_CACHE_ENDPOINT=grpc://atl-cache.services.bitrise.io:6666
;;
*)
export BITRISE_CACHE_ENDPOINT=grpcs://pluggable.services.bitrise.io
;;
esac


echo "Configuring Bitrise remote cache..."
envman add --key BITRISE_CACHE_ENDPOINT --value "$BITRISE_CACHE_ENDPOINT"

