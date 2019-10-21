#!/bin/bash
# Finds files not registered in portage

DIRLIST="/bin /etc /lib /lib32 /lib64 /opt /sbin
`ls /usr/ | grep -vE 'portage|local|src|lost\+found|i686-[^-]+-mingw32' | sed 's/\(.*\)/\/usr\/\1/'`
`ls /var/ | grep -vE 'portage|tmp|lost\+found|run|cache|doc|www|log' | sed 's/\(.*\)/\/var\/\1/'`"

EXCLUDES='\\
^/etc/make.conf|\\
^/etc/portage|\\
^/etc/libvirt/qemu|\\
/data/|\\
/.git/|\\
/.hg/|\\
^/opt/android-sdk-update-manager|\\
^/opt/cuda|\\
^/usr/lib/portage|\\
^/usr/lib/portage|\\
^/usr/lib/gedit-2|\\
^/var/db/pkg|\\
^/var/lib/libvirt/images|\\
\\.pyc|\\.pyo|\\
^/usr/share/mime'

REPLACES="
s~\/lib64\/~/lib/~g ;
s~^/usr/opt/~/opt/~ ;
s~\/asm-x86\/~/asm/~ ;
"

#   ===========================================================
#  ========================= C O D E ===========================
# ===============================================================
# summarize dirlist
DIRLIST="`echo $DIRLIST`"
echo "DIRLIST=$DIRLIST"

# exclude current perl, kernel modules, layman
EXCLUDES="$EXCLUDES\|`qlist -ICev perl | sed 's~[^0-9]*\([0-9]*\.[0-9]*\.[0-9]*\).*~\^\/usr\/lib\/perl5/\1\|\\\\~'`"
EXCLUDES="`echo $EXCLUDES | sed 's~\ ~~g ; s~\\\~~g ; s~|$~~'`"
EXCLUDES="$EXCLUDES\|^/lib/modules/`uname -r`"
EXCLUDES="$EXCLUDES\|^/lib/modules/`eselect --brief --color=no kernel list | sed 's~^linux-~~'`"
EXCLUDES="`echo $EXCLUDES | sed 's~\ ~~g ; s~\\\~~g ; s~|$~~'`"
[ -f /etc/layman/layman.cfg ] && LAYMAN_PATH=`grep --color=NO '^storage' /etc/layman/layman.cfg | cut -d: -f2 | tail -c+2` \
&& EXCLUDES="$EXCLUDES\|^$LAYMAN_PATH"
EXCLUDES="`echo $EXCLUDES | sed 's~\ ~~g ; s~\\\~~g ; s~|$~~'`"

# exlucde PORTDIR, LOCALDIR, DISTDIR, PKGDIR
source /etc/make.conf &>/dev/null
source /etc/portage/make.conf &>/dev/null
[ "" != "$PORTDIR" ] && EXCLUDES="$EXCLUDES\|^$PORTDIR"
[ "" != "$LOCALDIR" ] && EXCLUDES="$EXCLUDES\|^$LOCALDIR"
[ "" != "$DISTDIR" ] && EXCLUDES="$EXCLUDES\|^$DISTDIR"
[ "" != "$PKGDIR" ] && EXCLUDES="$EXCLUDES\|^$PKGDIR"

# summarize excludes
echo "EXCLUDES=$EXCLUDES"

# summarize replaces
REPLACES="`echo $REPLACES`"
echo "REPLACES=$REPLACES"

CURRENT_LIST=/tmp/current-$RANDOM.lst
PORTAGE_LIST=/tmp/portage-$RANDOM.lst
RESULT_LIST=/tmp/result-$RANDOM.lst

echo "Gathering information from portage..."
qlist --showdebug / | sed "$REPLACES" | sort -u >$PORTAGE_LIST

echo "Gathering information from file system..."
find -P $DIRLIST -type f 2>/dev/null | sed "$REPLACES" | grep -vE "$EXCLUDES" | sort -u >$CURRENT_LIST

echo "Searching for differences..."
diff $PORTAGE_LIST $CURRENT_LIST | grep -E '^>' | sed 's/> //' >$RESULT_LIST

echo "`wc -l $RESULT_LIST | cut -d" " -f1` orphaned files found:"
echo "-------------------------------------------------------------------------"
cat $RESULT_LIST

rm -f $PORTAGE_LIST $CURRENT_LIST $RESULT_LIST

exit 0

