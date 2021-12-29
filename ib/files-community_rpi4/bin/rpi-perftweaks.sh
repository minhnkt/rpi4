#!/bin/sh

ecmd="echo "; i=$(basename $0)
if [ -x /etc/custom/custfunc.sh ]; then . /etc/custom/custfunc.sh; ecmd="echm ${i} "; fi
#########!!! if [ -f /root/wrt.ini ]; then . /root/wrt.ini; fi



###################################################################################################
#NOTE: this is a cut down simplified version so its deliberately clunky
#special thanks to @SubZero @rhester72 @mint and others TBA for input
#@dlakelan


###################################################################################################
#the Gbs option is tested without SQM further tweaks to steering or
#service removal / affinity et. al. may be required depending on
#goal is latency VS max throughput

#specifically eth0-affinity off of core0 decreases latency no Gbs keeps them all on core0 best for under 550Mbs







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







#if [ "${PERFTWEAKS}" = "default" ] || [ "${POWERPROFILE}" = "quick" ]; then
if [ "${PERFTWEAKS}" = "default" ] || [ ! -z "${POWERPROFILE}" ]; then

	governor=$(cat /sys/devices/system/cpu/cpufreq/policy0/scaling_governor)
	#$ecmd "GOVERNOR[$governor]: $POWERPROFILE" #600000 750000 1000000 1500000 #echq
	
	if [ "$governor" = "ondemand" ]; then

		GOVmsg="${GOVmsg} upthresh:21"
		echo -n 21 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold && sleep 2

		GOVmsg="${GOVmsg} downfac:6" #10>6>5
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

#################$ecmd "GOVERNOR[$governor]: $POWERPROFILE" #600000 750000 
#################202107 600000 700000 800000 900000 1000000 1100000 1200000 1300000 1400000 1500000
#################$ecmd "GOVERNOR[$governor]: $POWERPROFILE" #600000 750000 1000000 1500000 #echq











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





RENICE=$(command -v renice)
#if [ ! -z "${PERFTWEAKS}" ] && [ ! -z "${RENICE}" ]; then
if [ "${PERFTWEAKS}" = "default" ]; then

	reniceprocess "dnsmasq" -5 #reniceprocess "dnsmasq" -7
	reniceprocess "uhttpd" 2
	reniceprocess "dropbear" 1
	#reniceprocess "wpad" 10 #slowsallnet?

	$ecmd "RENICE $RENICEmsg"
fi











tasksetpids() {
	local thispid=
	for thispid in $(pidof ${1}); do #oneonlybutmeh
		$TASKSET -apc ${2} $thispid 2>&1 >/dev/null
		TASKSETmsg="${TASKSETmsg} ${1}:${thispid}>${2}"
	done
}

servicecpuadjust() {
	
	#if [ -z "$gottaskset" ]; then echq "taskset:$TASKSET not available" && return 0; fi
	tasksetpids "nlbwmon" 3
	tasksetpids "collectd" 3
	tasksetpids "uhttpd" 2 ### spikes@io
	tasksetpids "odhcpd" 3 ### tasksetpids "odhcpd" 0-0
	tasksetpids "dropbear" 3 #maxes on file transfer
	#tasksetpids "wpad" 3
	#tasksetpids "hostapd" 3
	#tasksetpids "wpa-supplicant" 3

thispid=
for thispid in $(pidof dnsmasq); do
	$TASKSET -apc 3 $thispid 2>&1 >/dev/null
	TASKSETmsg="${TASKSETmsg} ${1}:${thispid}>${2}"
done

}


    TASKSET="$(command -v taskset-aarch64)"
	if [ ! -z "$TASKSET" ]; then
		servicecpuadjust
		$ecmd "TASKSET: $TASKSETmsg" #echo "taskset: $TASKSETmsg" >/dev/kmsg
	else	
		$ecmd "TASKSET:$TASKSET not available" #echo "taskset:$TASKSET not available" >/dev/kmsg
	fi






















findRUPT() {
	fgrep ${1} /proc/interrupts  | sed 's|^ ||g' | cut -d':' -f1 | \
		tr -s '\n' ' '
}









################################# NOT TOO SURE ABOUT THIS ONE - NEEDS some CHANGING TESTING afaik WAS for WIFI
################################# but not everyone has it || effects disk too?

mmcINTs="$(findRUPT mmc)"
mmcNEWVAL="c"

tRU=
if [ ! -z "$mmcINTs" ]; then
	for tRU in $mmcINTs; do
		intPREV=
		intPREV=$(grep . /proc/irq/$tRU/smp_affinity 2>/dev/null)
		echo -n ${mmcNEWVAL} > /proc/irq/$tRU/smp_affinity
		mmcINTmsg="${mmcINTmsg} ${mmcNEWVAL}:$intPREV>$tRU"
	done
else
	mmcINTmsg="noMMCintFOUND" #echo "$0 nommcirqfound" >/dev/console
fi

if [ ! -z "$mmcINTmsg" ]; then
	$ecmd "MMCINTs: ${mmcINTmsg}"
fi











eth0INTs="$(findRUPT eth0)"


tRU=
if [ ! -z "$eth0INTs" ]; then
	for tRU in $eth0INTs; do

		coreSET=${coreSET:-1}		
		
		intPREV=
		intPREV=$(grep . /proc/irq/$tRU/smp_affinity 2>/dev/null)

		if [ "$coreSET" -ne "$intPREV" ]; then
			echo -n $coreSET > /proc/irq/$tRU/smp_affinity #echo -n 1 > /proc/irq/$tRU/smp_affinity
		fi


		eth0INTmsg="$eth0INTmsg $tRU:${intPREV}>${coreSET}"

		if [ ! -z "$PERFTWEAKS_Gbs" ]; then #FOR Gbs 2nd interrupt to core 2 may effect latency
			coreSET=$((coreSET + 1))
		fi
	
	done
else
	eth0INTmsg="$0 eth0_no-irqfound" >/dev/console #echo "$0 eth0_no-irqfound" >/dev/console
fi

if [ ! -z "$eth0INTmsg" ]; then
	$ecmd "ETH0INT: $eth0INTmsg"
fi

























WANIFACE=$(ubus call network.interface.wan status | jsonfilter -e '@.device')
#$ecmd "WANIFACE: $WANIFACE"



LANIFACE=$(ubus call network.interface.lan status | jsonfilter -e '@.device')
case "$LANIFACE" in
	"br-"*)
		LANIFACE="$(brctl show br-lan | grep -v '^bridge name' | head -n1 | tr -s '\t' ' ' | cut -d' ' -f4)"
	;;
esac
#$ecmd "LANIFACE: $LANIFACE"


$ecmd "LANIFACE:$LANIFACE WANIFACE:$WANIFACE"







setAsysval() {

	local sysVAL="${1}"
	local sysPATH="${2}"
	local sysVALprev=


	if [ ! -e "${sysPATH}" ]; then
		$ecmd "sysPATHinvalid: $sysPATH"
		return 1
	fi


	sysVALprev=$(grep . $sysPATH 2>/dev/null)

	if [ "$sysVALprev" = "$sysVAL" ]; then
		$ecmd "sysval: $(echo $sysPATH | sed 's|/sys/class/net/||g')[${sysVALprev}=${sysVAL}]"
	else
		echo -n $sysVAL > ${sysPATH}
		$ecmd "sysval: $(echo $sysPATH | sed 's|/sys/class/net/||g')[${sysVALprev}>${sysVAL}]"
	fi


}
#echo -n $sysVAL > /sys/class/net/eth0/queues/tx-0/xps_cpus





#if [ "${PERFTWEAKS}" = "default" ]; then


################## TEMPORARY LOGIC! 20211227 ##########################
################## TEMPORARY LOGIC! 20211227 ##########################
################## TEMPORARY LOGIC! 20211227 ##########################

if [ "${PERFTWEAKS}" = "default" ] || [ ! -z "$PERFTWEAKS_Gbs" ]; then

################## TEMPORARY LOGIC! 20211227 ##########################
################## TEMPORARY LOGIC! 20211227 ##########################
################## TEMPORARY LOGIC! 20211227 ##########################


setAsysval "1" "/sys/class/net/eth0/queues/tx-0/xps_cpus"
#echo -n 1 > /sys/class/net/eth0/queues/tx-0/xps_cpus #0

setAsysval "2" "/sys/class/net/eth0/queues/tx-1/xps_cpus"
#echo -n 2 > /sys/class/net/eth0/queues/tx-1/xps_cpus #1


setAsysval "4" "/sys/class/net/eth0/queues/tx-2/xps_cpus"
#echo -n 4 > /sys/class/net/eth0/queues/tx-2/xps_cpus #2


setAsysval "4" "/sys/class/net/eth0/queues/tx-3/xps_cpus"
#echo -n 4 > /sys/class/net/eth0/queues/tx-3/xps_cpus #0 ###echo -n 1 > /sys/class/net/eth0/queues/tx-3/xps_cpus #0





setAsysval "2" "/sys/class/net/eth0/queues/tx-4/xps_cpus"
#echo -n 2 > /sys/class/net/eth0/queues/tx-4/xps_cpus #1


setAsysval "7" "/sys/class/net/eth0/queues/rx-0/rps_cpus"
#echo -n 7 > /sys/class/net/eth0/queues/rx-0/rps_cpus #0 #ORIGINAL echo -n 1 > /sys/class/net/eth0/queues/rx-0/rps_cpus #0



setAsysval "7" "/sys/class/net/${WANIFACE}/queues/rx-0/rps_cpus"
#echo -n 7 > /sys/class/net/${WANIFACE}/queues/rx-0/rps_cpus #012 #echo -n 7 > /sys/class/net/eth1/queues/rx-0/rps_cpus #012







############################################## 20211207 NEEDS TO GET REAL IFACES
############################################## is old/tmpoff code for this
############################################## or move back to hotplug
#/bin/rpi-perftweaks.sh: line 179: can't create /sys/class/net/eth1/queues/rx-0/rps_cpus: nonexistent directory
#NOTE 1 2 4 8
######################## OVERRIDEBACKtoALLonONE echo -n $coreSET > /proc/irq/$tRU/smp_affinity





############################################################ kongy CHECK THIS probably not needed here or current
sysctl -w vm.min_free_kbytes=65536 2>/dev/null 1>/dev/null 
sysctl -w net.netfilter.nf_conntrack_max=32768 2>/dev/null 1>/dev/null


fi









#if [ ! -z "$PERFTWEAKS_Gbs" ]; then
#	echo "PERFTWEAKS_Gbs [for sqm use please test alternate steering vals]" > /dev/kmsg

	###########################################################TEMPORARY UNTIL RE-ADD CUSTOM hotplug
	#########################SET steering all f's for now for hotplug AKA if device is replugged after boot
	if [ -z "$(uci -q show network | grep "network.globals.packet_steering='1'")" ]; then
		$ecmd "enabling packet steering [tmp-wip-ini-toggle-restore-etc]"
		uci set network.globals.packet_steering='1'
		uci commit network
	fi

#fi



#NOTE: needs old not Gbs but still want steering > MEH lets just enable for everyone? TEMPORARILY





















###TAILROOM-5.10_UNCOMMONBUG
if grep -q '^Version: 5.10' /usr/lib/opkg/info/kernel.control; then
	if [ "$(dmesg | grep tailroom | wc -l)" -gt 5 ]; then
		echo "tailroom_fix: ethtool -K eth0 rx off [apply-dmesg]" >/dev/kmsg
		ethtool -K eth0 rx off
	elif grep -q 'DC:A6:32:56:31:77' /proc/cmdline 2>/dev/null; then
		echo "tailroom_fix: ethtool -K eth0 rx off [apply_maintainer]" >/dev/kmsg
		ethtool -K eth0 rx off
	else
		echo "tailroom_fix: ethtool -K eth0 rx off [skip_notailroomindmesg]" >/dev/kmsg
	fi
else
	echo "tailroom_fix: ethtool -K eth0 rx off [skip_not_5.10]" >/dev/kmsg
fi




###TAILROOM-5.10_UNCOMMONBUG INI OPTIONAL(i dont use) interface_list i.e. EEE_DISABLE="eth0 eth1"
if [ ! -z "$EEE_DISABLE" ]; then
	for eNET in $EEE_DISABLE; do
		###echo "EEE_DISABLE: $eNET $(ethtool --set-eee $eNET eee off 1>/dev/kmsg 2>/dev/kmsg)" 1>/dev/kmsg
		echo "EEE_DISABLE: $eNET $(ethtool --set-eee $eNET eee off 2>&1)" 1>/dev/kmsg
	done
else
	echo "EEE_DISABLE [off]" >/dev/kmsg #echo "EEE_DISABLE [off]" >/dev/console
fi ### ethtool --show-eee eth1










exit 0





##########################################333 POSSIBLYCRASHING 5.10 disable
#####################20210731givethisatry
#ethtool -C eth0 tx-usecs 0
#ethtool -C eth1 tx-usecs 0
#ethtool -C eth0 rx-usecs 31
#########################thisissomethingbigbydefault
#ethtool -C eth1 rx-usecs 31




########################################################################## movedto rc.custom due to delaybghere
################### stops errors or genet.skip_umac_reset=n













###################################################################################
#    TASKSET="$(command -v taskset-aarch64)"
#	for thispid in $(pidof nlbwmon); do
#		$TASKSET -apc 3 $thispid 2>&1 >/dev/null
#	done
#	for thispid in $(pidof collectd); do
#		$TASKSET -apc 3 $thispid 2>&1 >/dev/null
#	done
#	for thispid in $(pidof uhttpd); do
#		$TASKSET -apc 2 $thispid 2>&1 >/dev/null
#	done
###################################################################################
#eth0INTs="$(findRUPT eth0)"
#tRU=
#if [ ! -z "$eth0INTs" ]; then
#	for tRU in $eth0INTs; do
#		coreSET=${coreSET:-1}
#		echo -n ${coreSET} > /proc/irq/$tRU/smp_affinity
#		coreSET=$((coreSET + 1))
#	done
#fi


#echo -n 1 > /sys/class/net/eth0/queues/tx-0/xps_cpus
#echo -n 2 > /sys/class/net/eth0/queues/tx-1/xps_cpus
#echo -n 4 > /sys/class/net/eth0/queues/tx-2/xps_cpus
#echo -n 4 > /sys/class/net/eth0/queues/tx-3/xps_cpus
#echo -n 2 > /sys/class/net/eth0/queues/tx-4/xps_cpus
#echo -n 7 > /sys/class/net/eth0/queues/rx-0/rps_cpus
#echo -n 7 > /sys/class/net/eth1/queues/rx-0/rps_cpus




#THISSECTIONMOVEDtoETCearlybootrpi() {
#BACKOFFAGAINdueTOMODDINGofTHATakaUSERSneedOPEWRTDEFAULTS

#and running all 5.10 for a while
#note: needs alt br-lan@eth1 detection

#make maintainer second to check dmsg detection











#findRUPT() {
#	fgrep ${1} /proc/interrupts  | sed 's|^ ||g' | cut -d':' -f1 | \
#		tr -s '\n' ' '
#}
#mmcINTs="$(findRUPT mmc)"
#eth0INTs="$(findRUPT eth0)"
#$ecmd "mmcINTs: $mmcINTs eth0INTs: $eth0INTs"
##echo "mmcINTs: $mmcINTs eth0INTs: $eth0INTs" >/dev/console
##############echo "mmcINTs: $mmcINTs"



#mmcINTs: 33  eth0INTs: 





###echo -n "1100000" > /sys/devices/system/cpu/cpufreq/policy0/scaling_min_freq
###echo -n 21 > /sys/devices/system/cpu/cpufreq/ondemand/up_threshold && sleep 2
###echo -n 5 > /sys/devices/system/cpu/cpufreq/ondemand/sampling_down_factor




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







#getwaniface() {
#	local iface
#	. /lib/functions/network.sh
#	network_find_wan iface
#	if [ -n "$iface" ]; then
#		echo "$iface"; return 0
#	fi
#	return 1
#}

#$ecmd "waniface: $(getwaniface)" #waniface: wan








#echo "EEE_DISABLE: $eNET $(ethtool --set-eee $eNET eee off 2>&1)" 1>/dev/kmsg





