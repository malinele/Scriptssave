#!/usr/bin/ksh
CHECK=$(echo $@ | wc -c)
case ${CHECK} in
	1 ) echo "Missing input parameters"
		exit 1
		;;
esac
HOURS="00 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23"
STREAMS="MMSC ADATA MCR40"
DESTINATION="/prusers/smlpkg1/smlep/var/sml/projs/up/physical/switch"

for HOUR in ${HOURS} 
	do
		for STREAM in ${STREAMS}
			do
				scp -p ./${STREAM}/*_T$1${HOUR}* smlep@smlpkg1.at.inside:${DESTINATION}${STREAM}
				ssh smlep@smlpkg1.at.inside "gunzip ${DESTINATION}${STREAM}/*_T$1${HOUR}*"
			done
	scp -p trt2.sh smlep@smlpkg1.at.inside:${DESTINATION}
	ssh smlep@smlpkg1.at.inside "cd ${DESTINATION}; ./trt2.sh $1${HOUR}"
	COUNT=$(ssh smlep@smlpkg1.at.inside "find ${DESTINATION} -type f -name "*.FIN" | wc -l")
	echo "Remaining FIN files for hour (${HOUR}): ${COUNT}"
	while [ ${COUNT} -gt 0 ]
		do
			echo "Sleeping .."; sleep 30
			COUNT=$(ssh smlep@smlpkg1.at.inside "find ${DESTINATION} -type f -name "*.FIN" | wc -l")
			echo "Remaining FIN files for hour (${HOUR}): ${COUNT}"
		done
	done