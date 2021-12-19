cd /etc/runlevels
rm -r nox
cp -r default nox
rc-update del xdm nox
rc-update del display-manager nox
rc-update del dbus nox
rc-update del consolekit nox
rc-update del bluetooth nox
rc-update del wicd nox
rc-update del NetworkManager nox
