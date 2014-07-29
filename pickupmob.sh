#!/bin/sh

###########################
#
# Configuration
#
###########################

Configuration() {

TIMESTAMP=`date +%s`
DESTINATIONS="mobep@mobpkg1.at.inside mobamc@mobpkg2.at.inside mobes1@mobesp1.at.inside mobes2@mobesp2.at.inside moboper@mobcust1.at.inside"
MPDESTINATIONS="mobep@mobpkg1.at.inside mobamc@mobpkg2.at.inside mobes1@mobesp1.at.inside mobes2@mobesp2.at.inside"
TEMPDEST="mobtc@mobpkg1.at.inside mobavm1@mobpkg1.at.inside mobavm2@mobpkg2.at.inside mobaem@mobpkg1.at.inside mobwl@webabp1.at.inside"
WORKDIR="/tmp/adx5"
WORKFILE="nagios.cmd"
CRITICALTCDAEMONS="G01_COLL|G01_COLL|mobpkg1 G01_ARCM|G01_ARCM|mobpkg1 G02_ARCM|G02_ARCM|mobpkg1 DB2E1013|DB2E1013|mobpkg1 DB2E1109|DB2E1109|mobpkg1 DSP1007|DSP1007|mobpkg1 DSP1116|DSP1116|mobpkg1 ELA1011|ELA1011|mobpkg1 F2E1024|F2E1024|mobpkg1 F2E1095|F2E1095|mobpkg1 F2E1106|F2E1106|mobpkg1 F2E1107|F2E1107|mobpkg1 GAT2E1015|GAT2E1015|mobpkg1 UQ_SERVER1027|UQ_SERVER1027|mobpkg1 US_EX_BOD1044|US_EX_BOD1044|mobpkg1 ES_RB1008|ES_RB1008|mobesp1 ES_RB1009|ES_RB1009|mobesp1 ES_RB1120|ES_RB1120|mobesp1 ES_RB1121|ES_RB1121|mobesp1 ES_FR1123|ES_FR1123|mobesp1 ES_FR1124|ES_FR1124|mobesp1 ES_RB1086|ES_RB1086|mobesp2 ES_RB1087|ES_RB1087|mobesp2 ES_RB1117|ES_RB1117|mobesp2 ES_RB1118|ES_RB1118|mobesp2 ES_FR1126|ES_FR1126|mobesp2 ES_FR1127|ES_FR1127|mobesp2"
NONCRITICALTCDAEMONS="RRP_OG1088|RRP_OG1088|mobesp2 RRP_OG1115|RRP_OG1115|mobesp2 RRP_OG1010|RRP_OG1010|mobesp1 RRP_OG1119|RRP_OG1119|mobesp1 ES_EOC1045|ES_EOC1045|mobpkg1 ES_EOC1135|ES_EOC1135|mobpkg1 ES_EOC1136|ES_EOC1136|mobpkg1 ES_EOC1138|ES_EOC1138|mobpkg1 ES_RORC1073|ES_RORC1073|mobpkg1 RCND1108|RCND1108|mobpkg1 RER1100|RER1100|mobpkg1 RERATE_MARK_DAEMON1005|RERATE_MARK_DAEMON1005|mobpkg1 RORC1077|RORC1077|mobpkg1"
AFDAEMONS="listener|PRELSN|mobpkg1 MF1ppLSN|MAFLSN1|mobpkg1 Ac1FtcManager|AC1MNGR|mobpkg1 TRB1Manager|TRBMNGR|mobpkg1 INSTANCE=MD|MD1|mobpkg1 amc1_DaemonManager|amc1_DaemonManager|mobpkg2"
AVMDAEMONS="AGENT1012|AGENT1012|mobpkg1 AGENT11|AGENT11|mobpkg1 AVM1001|AVM1001|mobpkg1 AGENT1006|AGENT1006|mobesp1 QUORUM1016|QUORUM1016|mobesp1 AGENT12|AGENT12|mobpkg2 AVM1003|AVM1003|mobpkg2 AGENT1031|AGENT1031|mobesp2"
UHDAEMONS="UHI_GD1038|UHI_GD1038|mobpkg1 UHI_RT1034|UHI_RT1034|mobpkg1"
ARCMDAEMONS="G01_COLL|G01_COLL|mobpkg1 G01_ARCM|G01_ARCM|mobpkg1 G02_ARCM|G02_ARCM|mobpkg1"
}


ExitProcess () {
        RC=${1}
        case ${RC} in
        0)      echo "\nEnded successfully!\n"
                exit ${RC}
                ;;
        1)      echo "\n\n"
                exit ${RC}
                ;;
        *)      echo "\n\n"
                exit ${RC}
                ;;
        esac
}

ProcessListPickup () {

    for DESTINATION in ${DESTINATIONS}
        do
        	ssh ${DESTINATION} 'ps -ef | grep -e mob | grep -v grep' >> ${WORKDIR}/tempnagios
        done
}

ProcessCheckARCM() {
TONAGIOS=""
for DAEMONDJC in ${ARCMDAEMONS}
        do
                DAEMON=`echo ${DAEMONDJC} | awk -F '|' '{print $1}'`
                DJC=`echo ${DAEMONDJC} | awk -F '|' '{print $2}'`
                _HOST=`echo ${DAEMONDJC} | awk -F '|' '{print $3}'`
                NAGIOSDAEMON=`echo ${DAEMON} | awk -F '_' '{print $1$2$3$4}'`
                NAGIOSDAEMON=`echo ${NAGIOSDAEMON} | awk -F '=' '{print $1$2$3$4}'`
                NUMPROC=0
                NUMPROC=`cat ${WORKDIR}/tempnagios | grep ${DAEMON} | wc -l`
                case $NUMPROC in
                        0)      REPORT="${DJC} Down"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};2;${REPORT}\n"
                                ;;

                        1)      REPORT="${DJC} Up"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};0;${REPORT}\n"
                                ;;

                        *)      REPORT="${DJC} Up"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};0;Number of processes: ${NUMPROC} ${REPORT}\n"
                                ;;
                esac
        done

HOSTREPORT=`echo ${TONAGIOS} | wc -l`
if [ ${HOSTREPORT} -gt 0 ]; then
        TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_HOST_CHECK_RESULT;${_HOST};0;Host&Reporting is up\n"
else
        TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_HOST_CHECK_RESULT;${_HOST};2;Host&Reporting is down\n"
fi
echo -e ${TONAGIOS} | cat >> ${WORKDIR}/${WORKFILE}


}



ProcessCheckUH() {
TONAGIOS=""
for DAEMONDJC in ${UHDAEMONS}
        do
                DAEMON=`echo ${DAEMONDJC} | awk -F '|' '{print $1}'`
                DJC=`echo ${DAEMONDJC} | awk -F '|' '{print $2}'`
                _HOST=`echo ${DAEMONDJC} | awk -F '|' '{print $3}'`
                NAGIOSDAEMON=`echo ${DAEMON} | awk -F '_' '{print $1$2$3$4}'`
                NAGIOSDAEMON=`echo ${NAGIOSDAEMON} | awk -F '=' '{print $1$2$3$4}'`
                NUMPROC=0
                NUMPROC=`cat ${WORKDIR}/tempnagios | grep 'DuhProcInst' | grep ${DAEMON} | wc -l`
                case $NUMPROC in
                        0)      REPORT="${DJC} Down"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};2;${REPORT}\n"
                                ;;

                        1)      REPORT="${DJC} Up"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};0;${REPORT}\n"
                                ;;

                        *)      REPORT="${DJC} Up"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};0;Number of processes: ${NUMPROC} ${REPORT}\n"
                                ;;
                esac
        done

HOSTREPORT=`echo ${TONAGIOS} | wc -l`
if [ ${HOSTREPORT} -gt 0 ]; then
        TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_HOST_CHECK_RESULT;${_HOST};0;Host&Reporting is up\n"
else
        TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_HOST_CHECK_RESULT;${_HOST};2;Host&Reporting is down\n"
fi
echo -e ${TONAGIOS} | cat >> ${WORKDIR}/${WORKFILE}


}


ProcessCheckTC() {
TONAGIOS=""
for DAEMONDJC in ${CRITICALTCDAEMONS}
        do
                DAEMON=`echo ${DAEMONDJC} | awk -F '|' '{print $1}'`
                DJC=`echo ${DAEMONDJC} | awk -F '|' '{print $2}'`
                _HOST=`echo ${DAEMONDJC} | awk -F '|' '{print $3}'`
                NAGIOSDAEMON=`echo ${DAEMON} | awk -F '_' '{print $1$2$3$4}'`      
                NAGIOSDAEMON=`echo ${NAGIOSDAEMON} | awk -F '=' '{print $1$2$3$4}'`        
                NUMPROC=0
                NUMPROC=`cat ${WORKDIR}/tempnagios | grep 'gcpf1fwcApp -p' | grep ${DAEMON} | wc -l`
                case $NUMPROC in
                        0)      REPORT="${DJC} Down"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};2;${REPORT}\n"
                                ;;

                        1)      REPORT="${DJC} Up"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};0;${REPORT}\n"
                                ;;

                        *)      REPORT="${DJC} Up"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};0;Number of processes: ${NUMPROC} ${REPORT}\n"
                                ;;
                esac
        done
 
HOSTREPORT=`echo ${TONAGIOS} | wc -l`
if [ ${HOSTREPORT} -gt 0 ]; then 
        TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_HOST_CHECK_RESULT;${_HOST};0;Host&Reporting is up\n"
else
        TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_HOST_CHECK_RESULT;${_HOST};2;Host&Reporting is down\n"
fi
echo -e ${TONAGIOS} | cat >> ${WORKDIR}/${WORKFILE}


}

ProcessCheckNONTC() {
TONAGIOS=""
for DAEMONDJC in ${NONCRITICALTCDAEMONS}
        do
                DAEMON=`echo ${DAEMONDJC} | awk -F '|' '{print $1}'`
                DJC=`echo ${DAEMONDJC} | awk -F '|' '{print $2}'`
                _HOST=`echo ${DAEMONDJC} | awk -F '|' '{print $3}'`
                NAGIOSDAEMON=`echo ${DAEMON} | awk -F '_' '{print $1$2$3$4}'`      
                NAGIOSDAEMON=`echo ${NAGIOSDAEMON} | awk -F '=' '{print $1$2$3$4}'`        
                NUMPROC=0
                NUMPROC=`cat ${WORKDIR}/tempnagios | grep 'gcpf1fwcApp -p' | grep ${DAEMON} | wc -l`
                case $NUMPROC in
                        0)      REPORT="${DJC} Down"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};1;${REPORT}\n"
                                ;;

                        1)      REPORT="${DJC} Up"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};0;${REPORT}\n"
                                ;;

                        *)      REPORT="${DJC} Up"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};0;Number of processes: ${NUMPROC} ${REPORT}\n"
                                ;;
                esac
        done

echo -e ${TONAGIOS} | cat >> ${WORKDIR}/${WORKFILE}


}

ProcessCheckAF() {
TONAGIOS=""
for DAEMONDJC in ${AFDAEMONS}
        do
                DAEMON=`echo ${DAEMONDJC} | awk -F '|' '{print $1}'`
                DJC=`echo ${DAEMONDJC} | awk -F '|' '{print $2}'`
                _HOST=`echo ${DAEMONDJC} | awk -F '|' '{print $3}'`
                NAGIOSDAEMON=`echo ${DAEMON} | awk -F '_' '{print $1$2$3$4}'`      
                NAGIOSDAEMON=`echo ${NAGIOSDAEMON} | awk -F '=' '{print $1$2$3$4}'`        
                NUMPROC=0
                NUMPROC=`cat ${WORKDIR}/tempnagios | grep ${DAEMON} | wc -l`
                case $NUMPROC in
                        0)      REPORT="${DJC} Down"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};1;${REPORT}\n"
                                ;;

                        1)      REPORT="${DJC} Up"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};0;${REPORT}\n"
                                ;;

                        *)      REPORT="${DJC} Up"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};0;Number of processes: ${NUMPROC} ${REPORT}\n"
                                ;;
                esac
        done
 
echo -e ${TONAGIOS} | cat >> ${WORKDIR}/${WORKFILE}


}

ProcessCheckAVM() {
TONAGIOS=""
for DAEMONDJC in ${AVMDAEMONS}
        do
                DAEMON=`echo ${DAEMONDJC} | awk -F '|' '{print $1}'`
                DJC=`echo ${DAEMONDJC} | awk -F '|' '{print $2}'`
                _HOST=`echo ${DAEMONDJC} | awk -F '|' '{print $3}'`
                NAGIOSDAEMON=`echo ${DAEMON} | awk -F '_' '{print $1$2$3$4}'`      
                NAGIOSDAEMON=`echo ${NAGIOSDAEMON} | awk -F '=' '{print $1$2$3$4}'`        
                NUMPROC=0
                NUMPROC=`cat ${WORKDIR}/tempnagios | grep gn1avm_  | grep ${DAEMON} | wc -l`
                case $NUMPROC in
                        0)      REPORT="${DJC} Down"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};2;${REPORT}\n"
                                ;;

                        1)      REPORT="${DJC} Up"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};0;${REPORT}\n"
                                ;;

                        *)      REPORT="${DJC} Up"
                                TONAGIOS=${TONAGIOS}"[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};${NAGIOSDAEMON};0;Number of processes: ${NUMPROC} ${REPORT}\n"
                                ;;
                esac
        done
 
echo -e ${TONAGIOS} | cat >> ${WORKDIR}/${WORKFILE}


}

#####################
# Mountpoint checking
#####################
mountpointchecking() {

for DESTINATION in ${MPDESTINATIONS}
    do
        MPSMPCHECK=`ssh ${DESTINATION} '~/pbin/op/ep.FSCheck.ksh'`
        WORDC=`echo ${MPSMPCHECK} | wc -w`
        _HOST=`echo ${DESTINATION} | awk -F '@' '{print $2}'  | awk -F '.' '{print $1}'`
        if [ ${WORDC} -ne 0 ]; then
        #PERCENTAGEP=`expr ${WORDC} - 1`
        PERCENTAGE=`echo ${MPSMPCHECK} | cut -f 1 -d " " | head -n 1`
        if [ ${PERCENTAGE} -ge 90 ]; then
            MPTONAGIOS="[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};MountPoint;2;${MPSMPCHECK}\n"
        else
            MPTONAGIOS="[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};MountPoint;1;${MPSMPCHECK}\n"
        fi
else
    MPTONAGIOS="[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};MountPoint;0;MountPoints OK\n"
fi
echo -e ${MPTONAGIOS} | cat >> ${WORKDIR}/${WORKFILE}      
done


}


CPUCheck() {

for DESTINATION in ${MPDESTINATIONS}
    do
        CPUCHECK=`ssh ${DESTINATION} '~/pbin/op/ep.CPUCheck.ksh'`
        WORDC=`echo ${CPUCHECK} | wc -w`
        _HOST=`echo ${DESTINATION} | awk -F '@' '{print $2}'  | awk -F '.' '{print $1}'`
        if [ ${WORDC} -ne 0 ]; then
        #PERCENTAGEP=`expr ${WORDC} - 1`
        PERCENTAGE=${CPUCHECK} 
        if [ ${PERCENTAGE} -ge 90 ]; then
            CPUTONAGIOS="[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};CPUCheck;2;${CPUCHECK} percent usage\n"
        else
            CPUTONAGIOS="[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};CPUCheck;1;${CPUCHECK} percent usage\n"
        fi
else
    CPUTONAGIOS="[${TIMESTAMP}] PROCESS_SERVICE_CHECK_RESULT;${_HOST};CPUCheck;0;CPU Usage below 80\n"
fi
echo -e ${CPUTONAGIOS} | cat >> ${WORKDIR}/${WORKFILE}
done
 

}


CopyAndCleanup () {

	scp ${WORKDIR}/${WORKFILE} /var/spool/nagios/cmd/
	rm ${WORKDIR}/${WORKFILE} ${WORKDIR}/tempnagios
}


#####################
# Main
#####################

main() {
        Configuration
        ProcessListPickup
        ProcessCheckTC
        ProcessCheckNONTC
        ProcessCheckAF
        ProcessCheckAVM
        mountpointchecking
	ProcessCheckUH
	ProcessCheckARCM
	CPUCheck
	CopyAndCleanup
}

main

