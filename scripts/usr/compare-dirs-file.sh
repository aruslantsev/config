BASEDIR="$PWD"

if [ -z "$1" ] || [ -z "$2" ]; then
	echo "Compares files in two directories"
	echo "Usage: ${0} [FIRST_DIR] [SECOND_DIR]"
	exit 1
fi

CURR="$1"
OLD="$2"

echo Collecting files...
cd "${CURR}"
find -type f > "${BASEDIR}/curr"
cd "${OLD}"
find -type f > "${BASEDIR}/old"

echo Calculating diff...
cd "$BASEDIR"
grep -F -f old curr > identical
rm old curr

echo Comparing files...
IFS=$'\n'
for file in $(cat identical); do 
	diff "${CURR}/${file}" "${OLD}/${file}" > /dev/null || echo "${file} has changes"
done

rm identical
echo Done.
