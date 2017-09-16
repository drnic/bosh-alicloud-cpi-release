#!/bin/bash

set -x

source /etc/profile.d/chruby.sh
chruby 2.1.2

semver=`cat version-semver/number`

# install bosh
echo "installing bosh..."
curl -O curl -O https://s3.amazonaws.com/bosh-cli-artifacts/bosh-cli-2.0.28-linux-amd64
chmod +x ./bosh-cli-*
mv ./bosh-cli-* /usr/local/bin/bosh

pushd bosh-cpi-src
  echo "running unit tests"
  pushd src/bosh_alicloud_cpi
    bundle install
    # bundle exec rspec spec/unit/*
    bundle exec rspec --tag debug spec/unit/cloud_spec.rb
  popd

  echo "using bosh CLI version..."
  bosh version

  cpi_release_name="bosh-alicloud-cpi"

  echo "building CPI release..."
  bosh create release --name $cpi_release_name --version $semver --with-tarball
popd

ls bosh-cpi-src

# mv bosh-cpi-src/dev_releases/$cpi_release_name/$cpi_release_name-$semver.tgz candidate/
mv bosh-cpi-src/README.md candidate/