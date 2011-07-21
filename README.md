# Prepare the environment

     yum install ruby-devel gcc gcc-c++ make which rpmdevtools git rpm-build mock
     gem install pkg-wizard merb-core merb-slices merb-assets merb-helpers merb-haml moneta bunny uuidtools rspec rake cucumber jeweler gemcutter

# Check out the sources

    git clone git@github.com:rubiojr/chef-rpms-builder.git

# Usage

    cd chef-rpms-builder
    ruby chef-rpms-builder --quiet

Use "--quiet" if you don't want to see debug output
