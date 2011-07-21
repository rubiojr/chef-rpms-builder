# Chef SRPMs build script

This script fetches chef package sources from http://github.com/frameos RPM repositories and creates SRPMS from Opscode's Chef master branch.

Either Fedora or RHEL/CentOS/SL is required to use this script

# Prepare the environment

First, we need to install some tools and build dependencies:

     yum install ruby-devel gcc gcc-c++ make which rpmdevtools git rpm-build mock
     gem install pkg-wizard merb-core merb-slices merb-assets merb-helpers 
     gem merb-haml moneta bunny uuidtools rspec rake cucumber jeweler gemcutter

# Check out the sources

Check out the build script sources:

    git clone git@github.com:rubiojr/chef-rpms-builder.git

# Usage

    cd chef-rpms-builder
    ruby chef-rpms-builder --quiet

Use "--quiet" if you don't want to see debug output
