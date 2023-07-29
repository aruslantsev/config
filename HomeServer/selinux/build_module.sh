checkmodule -M -m -o $1.mod $1.te
semodule_package -o $1.pp -m $1.mod
