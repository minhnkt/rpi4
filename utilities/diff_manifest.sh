#!/bin/bash






diff "${1}" "${2}" \
	| grep -Ev '(python|php|perlbase|kmod|collectd-mod)' | \
	grep -Ev '^[0-9]'


exit 0

diff manifest.21.02.0-1 rpi-4_21.02.1_1.0.6-2_r16325_extra/*mani* | grep -Ev '(python|php|perlbase)'






