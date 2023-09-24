cd /etc/runlevels
rm -r nox
cp -r default nox
rc-update del dbus nox
rc-update del bluetooth nox
rc-update del display-manager nox
