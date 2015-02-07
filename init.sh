#!/bin/sh

PATH=$PATH:/usr/local/bin/

# Update apt right away
apt-get -qq -y update

# Directory in which librarian-puppet should manage its modules directory
PUPPET_DIR=/etc/puppet/

$(which git > /dev/null 2>&1)
FOUND_GIT=$?
$(which librarian-puppet > /dev/null 2>&1)
FOUND_LP=$?

InstallLibrarianPuppetGem () {
  echo 'Installing Librarian-puppet gem, this may take a while...'
  RUBY_VERSION=$(ruby -e 'print RUBY_VERSION')
  case "$RUBY_VERSION" in
    1.8.*)
      # Install the most recent 1.x.x version, but not 2.x.x which needs Ruby 1.9
      gem install librarian-puppet --version "~>1"
      ;;
    *)
      gem install librarian-puppet
      ;;
  esac
  echo 'Librarian-puppet gem installed.'
}

apt-get -qq -y install git
apt-get -qq -y install ruby-json
apt-get -qq -y install ruby-dev

# Avoid gem install if LP is already installed
if [ "$FOUND_LP" -ne '0' ]; then
	InstallLibrarianPuppetGem
fi


if [ ! -d "$PUPPET_DIR" ]; then
  mkdir -p $PUPPET_DIR
fi
cp /vagrant/vagrant/Puppetfile $PUPPET_DIR

# Make sure librarian install is successful
set -e
cd $PUPPET_DIR && librarian-puppet install
set +e 

apt-get -qq -y install python-software-properties
apt-get -qq -y install build-essential

add-apt-repository ppa:nginx/stable
apt-get -qq -y update

add-apt-repository ppa:ondrej/php5
apt-get -qq -y update