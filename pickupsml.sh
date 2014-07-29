#!/bin/sh

###########################
#
# Configuration
#
###########################

Configuration() {

TIMESTAMP=`date +%s`
DESTINATIONS="smlep@smlpkg1.at.inside smlamc@smlpkg2.at.inside smles1@smlesp1.at.inside smles2@smlesp2.at.inside smloper@smlcust1.at.inside"
MPDESTINATIONS="smlep@smlpkg1.at.inside smlamc@smlpkg2.at.inside smles1@smlesp1.at.inside smles2@smlesp2.at.inside"
TEMPDEST="smltc@smlpkg1.at.inside smlavm1@smlpkg1.at.inside smlavm2@smlpkg2.at.inside smlaem@smlpkg1.at.inside smlwl@webabp1.at.inside"
WORKDIR="/tmp/adx5"
WORKFILE="nagiossml.cmd"
CRITICALTCDAEMONS="G01_COLL|G01_COLL|smlpkg1 G01_ARCM|G01_ARCM|smlpkg1 G02_ARCM|G02_ARCM|smlpkg1 DB2E1013|DB2E1013|smlpkg1 DB2E1109|DB2E1109|smlpkg1 DSP1007|DSP1007|smlpkg1 DSP1116|DSP1116|smlpkg1 ELA1011|ELA1011|smlpkg1 F2E1024|F2E1024|smlpkg1 F2E1095|F2E1095|smlpkg1 F2E1106|F2E1106|smlpkg1 F2E1107|F2E1107|smlpkg1 GAT2E1015|GAT2E1015|smlpkg1 UQ_SERVER1027|UQ_SERVER1027|smlpkg1 US_EX_BOD1044|US_EX_BOD1044|smlpkg1 ES_RB1008|ES_RB1008|smlesp1 ES_RB1009|ES_RB1009|smlesp1 ES_RB1120|ES_RB1120|smlesp1 ES_RB1121|ES_RB1121|smlesp1 ES_FR1123|ES_FR1123|smlesp1 ES_FR1124|ES_FR1124|smlesp1 ES_RB1086|ES_RB1086|smlesp2 ES_RB1087|ES_RB1087|smlesp2 ES_RB1117|ES_RB1117|smlesp2 ES_RB1118|ES_RB1118|smlesp2 ES_FR1126|ES_FR1126|smlesp2 ES_FR1127|ES_FR1127|smlesp2"
NONCRITICALTCDAEMONS="RRP_OG1088|RRP_OG1088|smlesp2 RRP_OG1115|RRP_OG1115|smlesp2 RRP_OG1010|RRP_OG1010|smlesp1 RRP_OG1119|RRP_OG1119|smlesp1 ES_EOC1045|ES_EOC1045|smlpkg1 ES_EOC1135|ES_EOC1135|smlpkg1 ES_EOC1136|ES_EOC1136|smlpkg1 ES_EOC1138|ES_EOC1138|smlpkg1 ES_RORC1073|ES_RORC1073|smlpkg1 RCND1108|RCND1108|smlpkg1 RER1100|RER1100|smlpkg1 RERATE_MARK_DAEMON1005|RERATE_MARK_DAEMON1005|smlpkg1 RORC1077|RORC1077|smlpkg1"
AFDAEMONS="listener|PRELSN|smlpkg1 MF1ppLSN|MAFLSN1|smlpkg1 Ac1FtcManager|AC1MNGR|smlpkg1 TRB1Manager|TRBMNGR|smlpkg1 INSTANCE=MD|MD1|smlpkg1 amc1_DaemonManager|amc1_DaemonManager|smlpkg2"
AVMDAEMONS="AGENT1012|AGENT1012|smlpkg1 AGENT11|AGENT11|smlpkg1 AVM1001|AVM1001|smlpkg1 AGENT1006|AGENT1006|smlesp1 QUORUM1016|QUORUM1016|smlesp1 AGENT12|AGENT12|smlpkg2 AVM1003|AVM1003|smlpkg2 AGENT1031|AGENT1031|smlesp2"
UHDAEMONS="UHI_GD1038|UHI_GD1038|smlpkg1 UHI_RT1034|UHI_RT1034|smlpkg1"
ARCMDAEMONS="G01_COLL|G01_COLL|smlpkg1 G01_ARCM|G01_ARCM|smlpkg1 G02_ARCM|G02_ARCM|smlpkg1"
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
        	ssh ${DESTINATION} 'ps -ef | grep sml | grep -v grep' >> ${WORKDIR}/tempnagiossml
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
                NUMPROC=`cat ${WORKDIR}/tempnagiossml | grep ${DAEMON} | wc -l`
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
                NUMPROC=`cat ${WORKDIR}/tempnagiossml | grep 'DuhProcInst' | grep ${DAEMON} | wc -l`
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
                NUMPROC=`cat ${WORKDIR}/tempnagiossml | grep 'gcpf1fwcApp -p' | grep ${DAEMON} | wc -l`
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
                NUMPROC=`cat ${WORKDIR}/tempnagiossml | grep 'gcpf1fwcApp -p' | grep ${DAEMON} | wc -l`
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
                NUMPROC=`cat ${WORKDIR}/tempnagiossml | grep ${DAEMON} | wc -l`
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
                NUMPROC=`cat ${WORKDIR}/tempnagiossml | grep gn1avm_  | grep ${DAEMON} | wc -l`
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

	scp ${WORKDIR}/${WORKFILE} /var/spool/nagios/cmd/nagios.cmd
	rm ${WORKDIR}/${WORKFILE} ${WORKDIR}/tempnagiossml
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

