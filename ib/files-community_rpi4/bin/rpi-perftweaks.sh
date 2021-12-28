#!/bin/sh

ecmd="echo "; i=$(basename $0)
if [ -x /etc/custom/custfunc.sh ]; then . /etc/custom/custfunc.sh; ecmd="echm ${i} "; fi
#########!!! if [ -f /root/wrt.ini ]; then . /root/wrt.ini; fi



















if [ "$1" = "boot" ]; then
	(sleep 35; $0)&
	exit 0
fi #this is needed to make sure services are started before renice












eval `grep '^PERFTWEAKS=' /root/wrt.ini 2>/dev/null`
eval `grep '^POWERPROFILE=' /root/wrt.ini 2>/dev/null`
eval `grep '^EEE_DISABLE=' /root/wrt.ini 2>/dev/null`

#20211226_@SubZero
eval `grep '^PERFTWEAKS_Gbs=' /root/wrt.ini 2>/dev/null`












case "$POWERPROFILE" in
   	"quickest")
		theMINfreq="1500000"
	;;
   	"quicker")
		#theMINfreq="1000000"
		theMINfreq="1300000"
	;;
	*) #quick nothing
		POWERPROFILE="quick"
		#theMINfreq="900000"
		theMINfreq="1100000"
	;;
esac
##$ecmd "GOVERNOR[$governor]: $POWERPROFILE" #600000 750000 













#if [ "${PERFTWEAKS}" = "default" ] || [ "${POWERPROFILE}" = "quick" ]; then
if [ "${PERFTWEAKS}" = "default" ] || [ ! -z "${POWERPROFILE}" ]; then


	governor=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor)
	#$ecmd "GOVERNOR[$governor]: $POWERPROFILE" #600000 750000 1000000 1500000 #echq
	
	if [ "$governor" = "ondemand" ]; then
	

GOVmsg="${GOVmsg} upthresh:21"
#echo -n 21 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold && sleep 2
echo -n 21 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold && sleep 2


GOVmsg="${GOVmsg} downfac:6" #10
#echo -n 6 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor #sleep 2
#################echo -n 30 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor #sleep 2
echo -n 5 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor #sleep 2




	
GOVmsg="${GOVmsg} minfreq:$theMINfreq"


echo -n "${theMINfreq}" > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq





GOVmsg="${GOVmsg} maxfreq:1500000"
echo -n '1500000' > /sys/devices/system/cpu/cpufreq/policy0/scaling_max_freq



	fi


	if [ ! -z "$GOVmsg" ]; then
		$ecmd "GOVERNOR[$governor]: $POWERPROFILE $GOVmsg"
	else
		$ecmd "GOVERNOR[$governor]: $POWERPROFILE $GOVmsg [nochange-or-altgov]"
	fi



fi














#202107 600000 700000 800000 900000 1000000 1100000 1200000 1300000 1400000 1500000
##$ecmd "GOVERNOR[$governor]: $POWERPROFILE" #600000 750000 1000000 1500000 #echq






reniceprocess() {

	local P_NAME="${1}"
	local P_VAL="${2}"

	RENICEmsg="${RENICEmsg} ${P_NAME}:${P_VAL}"
    	for dP in $(pidof ${P_NAME} 2>/dev/null ); do $RENICE ${P_VAL} $dP 2>/dev/null; done
    	

	#for dP in $(pidof ${P_NAME} 2>/dev/null ); do
	#	$ecmd "$RENICE ${P_VAL} $dP"
	#	$RENICE ${P_VAL} $dP
	#done

}








#set -x


RENICE=$(command -v renice)
#if [ ! -z "${PERFTWEAKS}" ] && [ ! -z "${RENICE}" ]; then
if [ "${PERFTWEAKS}" = "default" ]; then

	reniceprocess "dnsmasq" -5 #reniceprocess "dnsmasq" -7
	reniceprocess "uhttpd" 2
	reniceprocess "dropbear" 1
	#reniceprocess "wpad" 10 #slowsallnet?

	$ecmd "RENICE $RENICEmsg"
fi



































############################################## 20211207 NEEDS TO GET REAL IFACES
############################################## is old/tmpoff code for this
############################################## or move back to hotplug
#/bin/rpi-perftweaks.sh: line 179: can't create /sys/class/net/eth1/queues/rx-0/rps_cpus: nonexistent directory








if [ "${PERFTWEAKS}" = "default" ]; then




echo -n 1 > /sys/class/net/eth0/queues/tx-0/xps_cpus #0
echo -n 2 > /sys/class/net/eth0/queues/tx-1/xps_cpus #1
echo -n 4 > /sys/class/net/eth0/queues/tx-2/xps_cpus #2
#echo -n 1 > /sys/class/net/eth0/queues/tx-3/xps_cpus #0
echo -n 4 > /sys/class/net/eth0/queues/tx-3/xps_cpus #0
echo -n 2 > /sys/class/net/eth0/queues/tx-4/xps_cpus #1

#ORIGINAL echo -n 1 > /sys/class/net/eth0/queues/rx-0/rps_cpus #0
echo -n 7 > /sys/class/net/eth0/queues/rx-0/rps_cpus #0



echo -n 7 > /sys/class/net/eth1/queues/rx-0/rps_cpus #012








####################################################################################
#echo -n 7 > /sys/devices/virtual/net/br-lan/queues/rx-0/rps_cpus 2>/dev/null
####################################################################################
#############################slow? ifbresetonsqmrestart
#############################echo -n 7 > /sys/devices/virtual/net/ifb4eth1/queues/rx-0/rps_cpus 2>/dev/null
####################################################################################
#ethtool -K eth1 tx on sg on tso on 2>/dev/null 1>/dev/null
####################################################################################
####################################################################################
#echo -n 7 > /proc/irq/32/smp_affinity
############################################## pre-dwc WASON
#echo -n c > /proc/irq/26/smp_affinity
#echo -n 1 > /proc/irq/32/smp_affinity
#echo -n 1 > /proc/irq/33/smp_affinity
####################################################################################
######################### post DWC
# 28:     138044          0          0          0     GICv2 158 Level     mmc1, mmc0
# 34:    3166815          0          0          0     GICv2 189 Level     eth0
# 35:    3704034          0          0          0     GICv2 190 Level     eth0
# 28:     138044          0          0          0     GICv2 158 Level     mmc1, mmc0
####################################################################################













findRUPT() {

	#mmc
	fgrep ${1} /proc/interrupts  | sed 's|^ ||g' | cut -d':' -f1 | \
		tr -s '\n' ' '

}



#echo "fgrep eth0 /proc/interrupts  | sed 's|^ ||g' | cut -d':' -f1 | \
#		tr -s '\n' ' '"
#findRUPT eth0
#exit 0






mmcINTs="$(findRUPT mmc)"
eth0INTs="$(findRUPT eth0)"


$ecmd "mmcINTs: $mmcINTs eth0INTs: $eth0INTs"
echo "mmcINTs: $mmcINTs eth0INTs: $eth0INTs" >/dev/console



#echo "mmcINTs: $mmcINTs"
tRU=
if [ ! -z "$mmcINTs" ]; then
	for tRU in $mmcINTs; do
		#echo "echo -n c > /proc/irq/$tRU/smp_affinity"
		echo -n c > /proc/irq/$tRU/smp_affinity
		#||>/dev/console
	done
else
	echo "$0 nommcirqfound" >/dev/console
fi










#mmcINTs: 33  eth0INTs: 
#/bin/rpi-perftweaks.sh eth0irqfound





#echo "eth0INTs: $eth0INTs"
tRU=
if [ ! -z "$eth0INTs" ]; then
	for tRU in $eth0INTs; do

		coreSET=${coreSET:-1}
		#NOTE 1 2 4 8
		######################## OVERRIDEBACKtoALLonONE echo -n $coreSET > /proc/irq/$tRU/smp_affinity
		echo -n 1 > /proc/irq/$tRU/smp_affinity

		coreSET=$((coreSET + 1))

	
		######################echo "echo -n 1 > /proc/irq/$tRU/smp_affinity" #||>/dev/console
	done
else
	echo "$0 eth0_no-irqfound" >/dev/console
fi

















############################################################ kongy
sysctl -w vm.min_free_kbytes=65536 2>/dev/null 1>/dev/null 
sysctl -w net.netfilter.nf_conntrack_max=32768 2>/dev/null 1>/dev/null







fi















#######################################################333 POSSIBLYCRASHING 5.10 disable
#####################20210731givethisatry
#ethtool -C eth0 tx-usecs 0
#ethtool -C eth1 tx-usecs 0
#ethtool -C eth0 rx-usecs 31
#########################thisissomethingbigbydefault
#ethtool -C eth1 rx-usecs 31




########################################################################## movedto rc.custom due to delaybghere
################### stops errors or genet.skip_umac_reset=n















#THISSECTIONMOVEDtoETCearlybootrpi() {
#BACKOFFAGAINdueTOMODDINGofTHATakaUSERSneedOPEWRTDEFAULTS






#and running all 5.10 for a while
#note: needs alt br-lan@eth1 detection


#make maintainer second to check dmsg detection




if grep -q '^Version: 5.10' /usr/lib/opkg/info/kernel.control; then

	#ethtool -K eth0 rx off
	#if grep -q 'DC:A6:32:56:31:77' /proc/cmdline 2>/dev/null; then
	if [ "$(dmesg | grep tailroom | wc -l)" -gt 5 ]; then
		#echo "tailroom_fix: ethtool -K eth0 rx off [apply_maintainer]" >/dev/kmsg
		echo "tailroom_fix: ethtool -K eth0 rx off [apply-dmesg]" >/dev/kmsg
		ethtool -K eth0 rx off
	#elif [ "$(dmesg | grep tailroom | wc -l)" -gt 5 ]; then
	elif grep -q 'DC:A6:32:56:31:77' /proc/cmdline 2>/dev/null; then
		echo "tailroom_fix: ethtool -K eth0 rx off [apply_maintainer]" >/dev/kmsg
		#echo "tailroom_fix: ethtool -K eth0 rx off [apply-dmesg]" >/dev/kmsg
		ethtool -K eth0 rx off
	else
		echo "tailroom_fix: ethtool -K eth0 rx off [skip_notailroomindmesg]" >/dev/kmsg
	fi
		
else
	echo "tailroom_fix: ethtool -K eth0 rx off [skip_not_5.10]" >/dev/kmsg

fi











###########################}












if [ ! -z "$EEE_DISABLE" ]; then
	for eNET in $EEE_DISABLE; do
		###echo "EEE_DISABLE: $eNET $(ethtool --set-eee $eNET eee off 1>/dev/kmsg 2>/dev/kmsg)" 1>/dev/kmsg
		echo "EEE_DISABLE: $eNET $(ethtool --set-eee $eNET eee off 2>&1)" 1>/dev/kmsg
	done
else
	echo "EEE_DISABLE [off]" >/dev/kmsg #echo "EEE_DISABLE [off]" >/dev/console
fi
#ethtool --show-eee eth1

















    TASKSET="$(command -v taskset-aarch64)"
	for thispid in $(pidof nlbwmon); do
		$TASKSET -apc 3 $thispid 2>&1 >/dev/null
	done
	for thispid in $(pidof collectd); do
		$TASKSET -apc 3 $thispid 2>&1 >/dev/null
	done
	for thispid in $(pidof uhttpd); do
		$TASKSET -apc 2 $thispid 2>&1 >/dev/null
	done







###################################################################################



if [ ! -z "$PERFTWEAKS_Gbs" ]; then

	echo "PERFTWEAKS_Gbs" > /dev/kmsg


	
findRUPT() {
	fgrep ${1} /proc/interrupts  | sed 's|^ ||g' | cut -d':' -f1 | \
		tr -s '\n' ' '
}



eth0INTs="$(findRUPT eth0)"
tRU=
if [ ! -z "$eth0INTs" ]; then
	for tRU in $eth0INTs; do
		coreSET=${coreSET:-1}
		echo -n ${coreSET} > /proc/irq/$tRU/smp_affinity
		coreSET=$((coreSET + 1))
	done
fi



echo -n 1 > /sys/class/net/eth0/queues/tx-0/xps_cpus
echo -n 2 > /sys/class/net/eth0/queues/tx-1/xps_cpus
echo -n 4 > /sys/class/net/eth0/queues/tx-2/xps_cpus
echo -n 4 > /sys/class/net/eth0/queues/tx-3/xps_cpus
echo -n 2 > /sys/class/net/eth0/queues/tx-4/xps_cpus
echo -n 7 > /sys/class/net/eth0/queues/rx-0/rps_cpus
echo -n 7 > /sys/class/net/eth1/queues/rx-0/rps_cpus

###########################################################SET steering all f's for now for hotplug
if [ -z "$(uci -q show network | grep "network.globals.packet_steering='1'")" ]; then
	uci set network.globals.packet_steering='1'
	uci commit network
fi




#echo SQM use untested



fi


###################################################################################













exit 0





###echo -n "1100000" > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
###echo -n 21 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold && sleep 2
###echo -n 5 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor






##############################################################
#echo -n 6 > /proc/irq/32/smp_affinity
#echo -n 6 > /proc/irq/33/smp_affinity

##############################################################
#ethtool -K eth1 tx on sg on tso on 2>/dev/null 1>/dev/null
## #ethtool -C eth0 adaptive-rx on





###################Set defaults for TX and RX packet coalescing to be equivalent to:
# ethtool -C eth0 tx-frames 10
# ethtool -C eth0 rx-usecs 50

############ eth1 rx-usecs: 85000











#echo "EEE_DISABLE: $eNET $(ethtool --set-eee $eNET eee off 2>&1)" 1>/dev/kmsg





