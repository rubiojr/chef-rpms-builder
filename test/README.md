# Chef RPMs validation scripts

The scripts in this directory are intended to be run in a clean RHEL5/RHEL6 box (Either phy or a Vagrant box for example). You can use them as Vagrant shell provisioners to test Chef Server installs. For exaple:

    Vagrant::Config.run do |config|
      config.vm.box = "sl6-64-nochef"
    
      config.vm.forward_port "chef", 4040, 4040
      config.vm.forward_port "chef-api", 4000, 4000
      config.vm.provision :shell, :path => 'test-el6.sh'
    end

This Vagrant config starts a RHEL6 VM maps Chef Server ports and run the test-el6.sh script inside the VM. If test-el6.sh fails, you can pipe the error to an email and have something like a CI server.

# Available tests

test-el5.sh: setup a RHEL5 Chef Server using Chef nightly RPMs from RBEL and perform some tests.

test-el6.sh: setup a RHEL6 Chef Server using Chef nightly RPMs from RBEL and perform some tests.

# Usage

sudo -i /path/to/test-elX.sh
