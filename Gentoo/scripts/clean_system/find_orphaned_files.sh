#!/bin/bash

find / > all_files

contents=$(cat /var/db/pkg/*/*/CONTENTS | awk '{print $2}')
touch managed_files
for content in ${contents}; do
echo $content >> managed_files
done

sort -u all_files > all_sorted
sort -u managed_files > managed_sorted

comm -1 -3 managed_sorted all_sorted

rm all_files managed_files all_sorted managed_sorted
