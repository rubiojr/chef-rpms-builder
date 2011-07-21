# Chef SRPMs build script

This script fetches chef package sources from http://github.com/frameos RPM repositories and creates SRPMS from Opscode's Chef master branch.

Either Fedora or RHEL/CentOS/SL is required to use this script

If you want to build binary packages also, you will need pkg-wizard's buildbot. See Usage section for more details.

# Prepare the environment

If you are trying to build in RHEL5/CentOS5/SL5, you must install newer versions of ruby (1.8.7) and rubygems (>= 1.3.2) first. Up to date packages are available at http://rbel.frameos.org. You will also need EPEL repo to install Git.

First, we need to install some tools and build dependencies:

     yum install rpmdevtools rubygems ruby-devel gcc gcc-c++ make which rpmdevtools git rpm-build mock
     gem install pkg-wizard rake rest-client merb-core merb-slices merb-assets merb-helpers 
     gem merb-haml moneta bunny uuidtools rspec rake cucumber jeweler gemcutter

# Check out the sources

Check out the build script sources:

    git clone git://github.com/rubiojr/chef-rpms-builder.git

# Usage
    
Change to the builder directory

    cd chef-rpms-builder

Without build-bot (binary RPMS won't be created)

    ruby chef-rpms-builder --quiet

Use "--quiet" if you don't want to see debug output

If you want to use pkg-wizard's buildbot (see http://pkg-wizard.frameos.org)
to create binary RPMS:

    ruby chef-rpms-builder --quiet --use-buildbot


