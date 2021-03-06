#!/bin/zsh

#http://stackoverflow.com/questions/23182765/how-to-install-ia32-libs-in-ubuntu-14-04-lts

METASPLOIT="metasploit"
BASEACCT="wfu"

update()
{
  sudo apt-get -y update
  sudo apt-get -y install gcc-multilib
  sudo dpkg --add-architecture i386
  sudo apt-get -y install lib32z1 lib32ncurses5 lib32bz2-1.0

  # IDA Pro Dependencies
  sudo apt-get -y install lib32stdc++6 libfontconfig1:i386 libXrender1:i386 libsm6:i386 libfreetype6:i386 libglib2.0-0:i386 libxtst6:i386

  sudo apt-get -y install make
}

install_gui ()
{
  sudo apt-get -y install --no-install-recommends ubuntu-desktop
}

install_rvm()
{
  gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
  curl -sSL https://get.rvm.io | sudo bash -s stable 
  source /etc/profile
}

install_rev_tools ()
{
  # IDA Pro
  cd /home/$BASEACCT
  if  [ ! -d "idademo66" ]; then
    wget -O IdaDemo.tgz "https://out7.hex-rays.com/files/idademo68_linux.tgz"
	tar xvzf IdaDemo.tgz
	rm IdaDemo.tgz
	chown -R $BASEACCT:$BASEACCT idademo68
	su - $BASEACCT -c "ln -s idademo68/idaq idapro"
  fi

  # GDB
  sudo apt-get -y install gdb
}

perm_disable_aslr ()
{
  # Disable for future reboots
  if [ ! -f /etc/sysctl.d/01-disable-aslr.conf ] ; then
	sudo echo "kernel.randomize_va_space = 0" > /etc/sysctl.d/01-disable-aslr.conf
  fi

  # Disable for currently running system
  sysctl -w kernel.randomize_va_space="0"
}

install_git ()
{
  # Check if git is installed
  which git
  if [ $? ] ; then
    sudo apt-get -y install git
  fi
}

install_metasploit ()
{
  echo "Cloning metasploit"
  cd /home/$BASEACCT
 if [ ! -d "$METASPLOIT" ]; then
      git clone --depth=1 https://github.com/rapid7/metasploit-framework.git metasploit
  fi

  chown -R $BASEACCT:$BASEACCT metasploit

  # Install the required gems
  su -c $BASEACCT -c "echo \":update_sources: true\" > /home/$BASEACCT/.gemrc" 
  su -c $BASEACCT -c "echo \":benchmark: false\" >> /home/$BASEACCT/.gemrc"
  su -c $BASEACCT -c "echo \":backtrace: true\" >> /home/$BASEACCT/.gemrc"
  su -c $BASEACCT -c "echo \":verbose: true\" >> /home/$BASEACCT/.gemrc"
  su -c $BASEACCT -c "echo \"gem: --no-ri --no-rdoc\" >> /home/$BASEACCT/.gemrc"
  su -c $BASEACCT -c "echo \"install: --no-rdoc --no-ri\" >> /home/$BASEACCT/.gemrc"
  su -c $BASEACCT -c "echo \"update:  --no-rdoc --no-ri\" >> /home/$BASEACCT/.gemrc"
  cp /tmp/appsec2/gemrc "/home/$BASEACCT/.gemrc"
  cd metasploit
  echo "Install metasploit dependencies"
  apt-get -y install libpq-dev libxml2-dev libxslt1-dev libpcap-dev
  echo "Installing ruby"
#  su -c $BASEACCT -c "rvm install ruby-1.9.3-p547"
  rvm install ruby-1.9.3-p547
  echo "Installing gems"
  #su -c $BASEACCT -c "gem install bundler --no-ri --no-rdoc"
  gem install bundler --no-ri --no-rdoc
  su -c $BASEACCT -c "bundle install"
}

# Install Checksec
install_checksec ()
{
   if [ ! -f /home/$BASEACCT/checksec.sh ]; then
	wget -O /home/$BASEACCT/checksec.sh "http://www.trapkit.de/tools/checksec.sh"
	chmod +x /home/$BASEACCT/checksec.sh
	chown $BASEACCT:$BASEACCT /home/$BASEACCT/checksec.sh
	sudo apt-get -y install elfutils
  fi
}

create_basic_acct()
{
  # Check if the user exists
  getent passwd $BASEACCT 2>& /dev/null 
  if [[ $? -ne 0 ]] ; then
	echo "Need to create: $BASEACCT "
	useradd -d /home/$BASEACCT -m -p $(openssl passwd -1 $BASEACCT) -s /bin/bash $BASEACCT  -G rvm
  fi
}

create_user_acct()
{
	# Check if the user exists
	getent passwd $1 2>& /dev/null 
	if [[ $? -ne 0 ]] ; then
	  echo "Need to create: $1"
	  # Reference: http://www.howtogeek.com/howto/30184/
	  newPass=$(date +%s | sha256sum | base64 | head -c 32 ; echo)
	  sleep 1
	  useradd -d /home/$1 -m -p $(openssl passwd -1 $newPass) -s /bin/bash $1 -G rvm
	else
	  # Switch the shell back for now, just to help provisioning
	  usermod -s /bin/bash $1 
	fi
}

install_exercises ()
{
  echo "Installing exercises"
  ls -ladh /tmp/appsec2
  ls -ladh /tmp

  # Install tool to make the stack executable
  sudo apt-get -y install execstack

  # Install the stack examples
  for i in `ls /tmp/appsec2/stack*.c` ; do
	acct=$(echo $i | cut -d'.' -f1 | cut -d'/' -f4)
	create_user_acct $acct 
	cp $i /home/$acct/
	cp /tmp/appsec2/Makefile-$acct /home/$acct/Makefile
	#cp /tmp/appsec2/$acct-key.txt /home/$acct/key.txt
	#su - $acct -c "cd /home/$acct ; make unprotected ; chmod +s $acct ; chmod 400 key.txt"
	chown $acct:$acct /home/$acct/*
	su - $acct -c "cd /home/$acct ; make unprotected ; chmod +s $acct"
#	usermod -s /usr/sbin/nologin $acct
  done

  # Install the format string examples
  for i in `ls /tmp/appsec2/format*.c` ; do
	acct=$(echo $i | cut -d'.' -f1 | cut -d'/' -f4)
	create_user_acct $acct
	cp $i /home/$acct/
	cp /tmp/appsec2/Makefile-$acct /home/$acct/Makefile
	#cp /tmp/appsec2/$acct-key.txt /home/$acct/key.txt
	#su - $acct -c "cd /home/$acct ; make unprotected ; chmod +s $acct ; chmod 400 key.txt"
	chown $acct:$acct /home/$acct/*
	su - $acct -c "cd /home/$acct ; make unprotected ; chmod +s $acct"
#	usermod -s /usr/sbin/nologin $acct
  done

  # Install the reverse engineering bomb
  for i in `ls /tmp/appsec2/rev*` ; do 
	acct=$(echo $i | cut -d'.' -f1 | cut -d'/' -f4)
	create_user_acct $acct
	cp $i /home/$acct/
	cp /tmp/appsec2/README-$acct.txt /home/$acct/README.txt
	chown $acct:$acct /home/$acct/*
	chmod a+x /home/$acct/$acct
#	usermod -s /usr/sbin/nologin $acct
  done

}

install_gera()
{
  if [ ! -d /home/$BASEACCT/geras-insecure-programming ]; then
	  mkdir /home/$BASEACCT/geras-insecure-programming
	  chown $BASEACCT:$BASEACCT /home/$BASEACCT/geras-insecure-programming
  fi

  su - $BASEACCT -c "cp -R /tmp/appsec2/gera/*.c /home/$BASEACCT/geras-insecure-programming"
}

update
install_gui
install_git
install_rvm
create_basic_acct
install_checksec
install_metasploit
install_rev_tools
perm_disable_aslr
install_exercises
install_gera
