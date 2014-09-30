##################
# Part of wsp.pl #
##################

#!/bin/bash
source /root/.bash_profile

#Dont forget to change path

case "$1" in
	"parse")
		perl /root/bin/wsp/wsp.pl parse
		;;
	"send")
		perl /root/bin/wsp/wsp.pl send
		;;
	*)
		echo "Usage: $0 [parse|send]"
		;;
esac
