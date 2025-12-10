#!/bin/bash
echo "Run this script as a user with sudo permissions."
echo "Removing snap version of Firefox. Couldn't get this version working."
sudo snap remove firefox
echo "Adding Mozilla Repo for up-to-date firefox-esr download."
sudo add-apt-repository ppa:mozillateam/ppa || exit 1
sudo apt-get update || exit 1
echo "Installing Smartcard packages and enabling service."
sudo apt-get install coolkey opensc opensc-pkcs11 libnss3-tools pcscd pcsc-tools || exit 1
sudo apt-get upgrade
sudo systemctl enable --now pcscd
echo "Installing browser(s)..."
sudo apt-get install chromium-browser firefox-esr
echo 'Verify PCSC is working You should see readers and cards.'
pcsc_scan -r
pcsc_scan -c
echo 'Verify PKCS11 is working attempt to login.'
pkcs11-tool --test --login
echo 'Verify PKCS15 is working attempt to login.'
pkcs15-tool -v --verify-pin
#echo 'Add snap links to library modules.'
#ln -s /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so ~/snap/firefox/common/opensc-pkcs11.so
#ln -s /lib/pkcs11/libcoolkeypk11.so ~/snap/firefox/common/libcoolkeypk11.so
#snap connect firefox:pcscd
#snap connect chromium:pcscd
echo 'Add module(s) to chromium database.'
mkdir -p ~/.pki/nssdb
modutil -dbdir sql:$HOME/.pki/nssdb/ -add "Coolkey" -libfile /lib/pkcs11/libcoolkeypk11.so
modutil -dbdir sql:$HOME/.pki/nssdb/ -add "OpenSC" -libfile /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
