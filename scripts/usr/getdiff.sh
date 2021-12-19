BASEDIR="$PWD"

if [ -z "$1" ]
then
        PREFIX="/srv/shares/elena"
else
        PREFIX="$1"
fi

if [ -z "$2" ]
then
        CURR="backup"
else
        CURR="$2"
fi

if [ -z "$3" ]
then
        OLD="backup-old"
else
        OLD="$3"
fi

echo Collecting files...
cd "${PREFIX}/${CURR}"
find -type f > "${BASEDIR}/curr"
cd "${PREFIX}/${OLD}"
find -type f > "${BASEDIR}/old"

echo Calculating diff...
cd "$BASEDIR"
grep -F -f old curr > identical
rm old curr

echo Comparing files...
IFS=$'\n'
for file in $(cat identical)
do diff "${PREFIX}/${CURR}/${file}" "${PREFIX}/${OLD}/${file}" > /dev/null || echo "$file"
done

rm identical
echo Done.
