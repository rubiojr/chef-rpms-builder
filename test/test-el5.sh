#!/bin/sh

LOGFILE=/vagrant/shellout.log

run(){
	echo -n "Running '$@' ... "
	$@ >> $LOGFILE 2>&1
	if [ $? != 0 ]; then
		echo 'Failed'
		exit 1
	else
		echo 'Ok'
	fi
}

run rpm --force -Uvh http://rbel.co/rbel5
cat > /etc/yum.repos.d/nightly.repo <<EOF
[rbel-nightly]
name=rbel nightly
baseurl=http://rbel.frameos.org/nightly/el5/\$basearch/
gpgcheck=1
enabled=1
EOF
run yum install -y rubygem-chef-server wget
run setup-chef-server.sh
run mkdir /root/.chef
run knife configure -i -r /var/chef/ --defaults --yes -s http://localhost:4000
run cp /vagrant/client.rb /etc/chef/
run chef-client -N vagrant -c /etc/chef/client.rb -K /etc/chef/validation.pem
run wget --quiet http://s3.amazonaws.com/opscode-community/cookbook_versions/tarballs/799/original/yum.tgz
run wget --quiet http://s3.amazonaws.com/opscode-community/cookbook_versions/tarballs/837/original/yumrepo.tgz
run tar xzf yum.tgz
run tar xzf yumrepo.tgz
run knife cookbook -c /root/.chef/knife.rb upload -o . yum yumrepo
run knife node -c /root/.chef/knife.rb run_list add vagrant 'recipe[yumrepo]'
run rpm --force -Uvh http://rbel.co/epel5
run chef-client -N vagrant -c /etc/chef/client.rb
