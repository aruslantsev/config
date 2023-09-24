#!/usr/bin/python
# This script tries to find orphaned files in /etc
# based upon the information from portage.
#
# by Phillip 'Firebird' Berndt
#
import sys, glob, re, os, os.path
staticProtections = [
	"/etc/config-archive", "/etc/passwd", "/etc/shadow",
	"/etc/runlevels", "/etc/group", "/etc/gshadow",
	"/etc/make.conf", "/etc/make.profile", "/etc/magic",
	"/etc/ssl", "/etc/runlevels", "/etc/ssl", "/etc/gtk",
	"/etc/env.d", "/etc/portage", "/etc/gconf"
	]

sys.stderr.write("Creating list of protected files\n")
protectedFiles = ["/etc"]
for fileList in glob.glob("/var/db/pkg/*/*/CONTENTS"):
	for file in open(fileList).read().split("\n"):
		match = re.match("^(dir|obj) (/etc/[^ ]+)", file)
		if match: protectedFiles.append(match.group(2))

sys.stderr.write("Comparing against files in /etc/\n")
def checkFile(file):
	if file in protectedFiles: return False
	for other in staticProtections:
		if file.find(other) == 0: return False
	return True
for file in os.popen("find /etc").read().split("\n"):
	if checkFile(file): print(file)

