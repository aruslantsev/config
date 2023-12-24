VueScan tries to access the internet. To prevent it run

```
iptables -A OUTPUT -d 198.65.45.75 -j DROP
iptables -A OUTPUT -d 162.243.24.127 -j DROP
```

Add to /etc/hosts following

```
127.0.0.1 hamrick.com
127.0.0.1 www.hamrick.com
127.0.0.1 static.hamrick.com
127.0.0.1 stats.hamrick.com
127.0.0.1 d1t4l16dpbiwrj.cloudfront.net 
```

Or just disconnect from the internet before running vuescan.

99-local.rules is needed to create a device accessible by user. Otherwise you will need
to change the owner of the device or run vuescan as root. In gentoo it was solved by 
adding user to plugdev group.
