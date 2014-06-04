if test -f .vbox_version ; then
  # The netboot installs the VirtualBox support (old) so we have to remove it
  if test -f /etc/init.d/virtualbox-ose-guest-utils ; then
    /etc/init.d/virtualbox-ose-guest-utils stop
  fi

  rmmod vboxguest
  aptitude -y purge virtualbox-ose-guest-x11 virtualbox-ose-guest-dkms virtualbox-ose-guest-utils

  # Install dkms for dynamic compiles

  apt-get install -y dkms sed

  # If libdbus is not installed, virtualbox will not autostart
  apt-get -y install --no-install-recommends libdbus-1-3

  # Install the VirtualBox guest additions
  VBOX_VERSION=$(cat .vbox_version)
  VBOX_ISO=VBoxGuestAdditions_$VBOX_VERSION.iso
  mount -o loop $VBOX_ISO /mnt
  #yes|sh /mnt/VBoxLinuxAdditions.run
  # Patchin install script to use gid 999 for group vboxsf
  mkdir /tmp/vbox
  cp -R /mnt/* /tmp/vbox
  export SETUP_NOCHECK=1;
  sed 's/groupadd -f vboxsf/groupadd -f -g 999 vboxsf/' /tmp/vbox/VBoxLinuxAdditions.run > /tmp/vbox/patched.sh
  yes | sh /tmp/vbox/patched.sh
  umount /mnt
  ln -s /opt/VBoxGuestAdditions-4.3.10/lib/VBoxGuestAdditions /usr/lib/VBoxGuestAdditions

  # Start the newly build driver
  /etc/init.d/vboxadd start

  # Make a temporary mount point
  mkdir /tmp/veewee-validation

  # Test mount the veewee-validation
  mount -t vboxsf veewee-validation /tmp/veewee-validation

  rm $VBOX_ISO
  rm -rf /tmp/vbox

fi
