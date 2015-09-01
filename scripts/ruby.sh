set -x
echo "Configuring Ruby installation..."
echo

echo setting up rvm
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
echo "rvm_install_on_use_flag=1" >> $HOME/.rvmrc
rvm use 2.2.2 --default

echo installing Bundler
gem install bundler -N >/dev/null 2>&1

echo
echo "Done!"
echo
