#!/bin/bash

ip=/bin/ip

usage() { echo "Usage: 
	$0 -i dev -t int>0 -w int>0 -c int>0"
echo "Options:
	-h  show this page;
	-t  time interval between checks, in sec (default = 1sec);
	-i  name of network interface;
	-w  warning level (in KB) integer more then zero;
	-c  critical level (in KB) integer more then zero;"
exit 2;
}

prnt () {
	if [[ ${rx_rate:0:1} = \. ]]; then rx_rate=${rx_rate/\./0.}; fi
        if [[ ${tx_rate:0:1} = \. ]]; then tx_rate=${tx_rate/\./0.}; fi
	echo "$code - $int:$state in-rate:${rx_rate}KB out-rate:${tx_rate}KB";
}

while getopts ":hi:t::w:c:" opt; do
  case $opt in
    h)  usage;;
    \?) echo "Invalid option \"$OPTARG\" Please check help page"; exit 2;;
    i)  int=$OPTARG;;
    t)  [[ $OPTARG -gt 0 ]] && t=$OPTARG || t=1;;
    w)  [[ $OPTARG -gt 0 ]] && warn_lvl=$OPTARG || usage;;
    c)  [[ $OPTARG -gt 0 ]] && crit_lvl=$OPTARG || usage;;
    :) echo "Option \"$OPTARG\" requires an argument."; exit 2;;
    *)  usage;;
  esac
done

if [[ -z $t ]] || [[ -z $crit_lvl ]] || [[ -z $warn_lvl ]] || [[ -z $int ]]; then usage; fi

state=$(ip -s link show $int | xargs| cut -d " " -f9);
for i in {1,2};do 
	read rx$i tx$i <<< $(ip -s link show $int | xargs| cut -d " " -f27,40);
	[[ $i -eq 1 ]] && sleep $t;
done
rx_rate=$(echo "scale=2;(($rx2 - $rx1) / $t) / 1024" | bc -l)
tx_rate=$(echo "scale=2;(($tx2 - $tx1) / $t) / 1024" | bc -l)

if [ $(bc <<< "$warn_lvl>$rx_rate") -eq 1 -a $(bc <<< "$crit_lvl>$rx_rate") -eq 1 -a $(bc <<< "$warn_lvl>$tx_rate") -eq 1 -a $(bc <<< "$crit_lvl>$tx_rate") -eq 1 ]; then
	code=OK; 
	prnt;
	exit 0;
elif [ $(bc <<< "$crit_lvl<$rx_rate") -eq 1 -o $(bc <<< "$crit_lvl<$tx_rate") -eq 1 ]; then
        code="CRITICAL";
	prnt;
        exit 2;
elif [ $(bc <<< "$warn_lvl<$rx_rate") -eq 1 -o $(bc <<< "$warn_lvl<$tx_rate") -eq 1 ]; then
	code="WARNING";
	prnt;
	exit 1;
else
	code="UNKNOWN";
	prnt;
	exit 3;
fi
