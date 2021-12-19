find /srv/shares -name .AppleDouble # -exec rm -r {} \;
find /srv/shares -name "._*" # -delete
find /srv/shares -name "*.DS_Store" # -delete
find /srv/shares -name ".directory" # -delete
# check /var/netatalk
