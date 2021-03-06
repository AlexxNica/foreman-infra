#!/bin/bash
set -xe

# Script to copy the newly-built debs to the web node for signing and promoting
# Dependencies
# * the freight::client class in foreman-infra
# * the web node must have the freight class applied

# Find the deps in the build-dir from the previous step
DEB_PATH=./plugins/build-${project}

# Don't upload scratch builds to deb.tf.o
if [ x$repoowner = xtheforeman ] && [ x$pr_number = x ]; then
  echo "Built from main repo, uploading to deb/plugins/main"
  export RSYNC_RSH="ssh -i /var/lib/workspace/workspace/deb_key/rsync_freight_key"
  USER=freight
  HOST=deb
  if [ x$repo = xdevelop ]; then
    COMPONENT=nightly
  else
    COMPONENT=$repo
  fi
else
  echo "scratch build: uploading to stagingdeb/plugins/${repoowner}"
  export RSYNC_RSH="ssh -i /var/lib/workspace/workspace/staging_key/rsync_freightstage_key"
  USER=freightstage
  HOST=web02
  COMPONENT=${repoowner}
fi

# The path is important, as freight_rsync (which is run on the web node for incoming
# transfers) will parse the path to figure out the repo to send debs to.
TARGET_PATH="${USER}@${HOST}.theforeman.org:rsync_cache/plugins/${COMPONENT}/"

/usr/bin/rsync -avPx $DEB_PATH/*deb $TARGET_PATH
