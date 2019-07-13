./checketc.py > etc_list
./fcruft/bin/findcruft > 1_list
./cleaner.sh > 2_list
cat etc_list 1_list 2_list | sort | uniq > list
./postprocess.sh list list_postprocessed
