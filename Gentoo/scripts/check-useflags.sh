for FLAG in $USE; do
	echo "${FLAG} : $(equery h $(sed 's/^\-//' <<<  ${FLAG}) | wc -l)"
done
