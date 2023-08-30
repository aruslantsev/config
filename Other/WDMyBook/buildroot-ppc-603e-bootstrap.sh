#!/bin/sh
feed=http://ipkg.nslu2-linux.org/optware-ng/buildroot-ppc-603e
ipk_name=$(wget -qO- $feed/Packages | awk '/^Filename: ipkg-static/ {print $2}')
wget -O /tmp/$ipk_name $feed/$ipk_name
tar -C /tmp -xvzf /tmp/$ipk_name ./data.tar.gz
tar -C / -xzvf /tmp/data.tar.gz
rm -f /tmp/$ipk_name /tmp/data.tar.gz
echo "src/gz optware-ng $feed" > /opt/etc/ipkg.conf
echo "dest /opt/ /" >> /opt/etc/ipkg.conf

PATH=$PATH:/opt/bin:/opt/sbin

echo "Bootstraping done"

echo "Installing glibc-locale package to generate needed /opt/lib/locale/locale-archive"
echo "================================================================================="

/opt/bin/ipkg update
/opt/bin/ipkg install glibc-locale

echo "================================================================================="
echo "Removing glibc-locale package to save space: this doesn't remove generated /opt/lib/locale/locale-archive"

/opt/bin/ipkg remove glibc-locale
