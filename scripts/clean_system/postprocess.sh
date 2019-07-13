#!/bin/bash

cat $1 | grep -v ^\/home\/ | grep -v ^\/dev\/ | grep -v ^\/proc\/ | grep -v ^\/sys\/ | grep -v ^\/usr\/portage\/ | grep -v ^\/usr\/src\/ | grep -v ^\/var\/db\/ | grep -v ^\/var\/tmp\/ccache\/ | grep -v ^\/root\/ > $2
