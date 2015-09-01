apt-get -yqq update
apt-get -yqq install curl lsb-release
curl -L https://www.chef.io/chef/install.sh | sudo bash
apt-get -yqq clean

