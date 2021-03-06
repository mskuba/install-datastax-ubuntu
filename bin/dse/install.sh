#!/usr/bin/env bash

cloud_type=$1

# Set DSE, OpsC versions.
# Overidable by setting env var in calling template,
# eg: export OPSC_VERSION='6.1.0'

dse_version=5.1.1-1
opscenter_version=6.1.0

if [ -z "$OPSC_VERSION" ]
then
  echo "env \$OPSC_VERSION is not set, using default: $opscenter_version"
else
  echo "env \$OPSC_VERSION is set: $OPSC_VERSION overiding default"
  opscenter_version=$OPSC_VERSION
fi

if [ -z "$DSE_VERSION" ]
then
  echo "env \$DSE_VERSION is not set, using default: $dse_version"
else
  echo "env \$DSE_VERSION is set: $DSE_VERSION overiding default"
  dse_version=$DSE_VERSION
fi

echo "Installing DataStax Enterprise"

echo "Adding the DataStax repository"
if [[ $cloud_type == "gce" ]] || [[ $cloud_type == "gke" ]]; then
  echo "deb http://datastax%40google.com:8GdeeVT2s7zi@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
else
  echo "deb http://datastax%40microsoft.com:3A7vadPHbNT@debian.datastax.com/enterprise stable main" | sudo tee -a /etc/apt/sources.list.d/datastax.sources.list
fi

curl -L http://debian.datastax.com/debian/repo_key | sudo apt-key add -
apt-get -y update

echo "Running apt-get install dse"
apt-get -y install dse-full=$dse_version dse=$dse_version dse-demos=$dse_version dse-libsolr=$dse_version dse-libtomcat=$dse_version dse-liblog4j=$dse_version dse-libcassandra=$dse_version dse-libspark=$dse_version dse-libhadoop2-client-native=$dse_version dse-libgraph=$dse_version dse-libhadoop2-client=$dse_version

echo "Running apt-get install datastax-agent"
apt-get -y install datastax-agent=$opscenter_version

# The install of dse creates a cassandra user, so now we can do this:
chown cassandra /mnt
chgrp cassandra /mnt
