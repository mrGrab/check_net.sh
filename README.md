# check_net.sh
<h6>nagios bash-plugin to check in/out rate on network interface.</h6>
<br />
based on ip tool it checks RX and TX value of specified interface within some interval and provide speed in KB
<pre>
Usage: 
	./check_net.sh -i dev -t int>0 -w int>0 -c int>0
Options:
	-h  show this page;
	-t  time interval between checks, in sec (default = 1sec);
	-i  name of network interface;
	-w  warning level (in KB) integer more then zero;
	-c  critical level (in KB) integer more then zero;
</pre>
