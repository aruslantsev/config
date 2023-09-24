mkdir "${1}_zip"
mogrify -compress Zip -path "${1}_zip/" "${1}/*tif"
