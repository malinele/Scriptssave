#!/usr/bin/ksh
CHECK=$(echo $@ | wc -c)
case ${CHECK} in
	1 ) echo "Missing input parameters"
		exit 1
		;;
esac

DESTINATION="~/users/nenad/"
#DESTINATION="${ASMM_DATA_HOME}/INPUT/TAPIN_CD"

touch -t ${1}0000 startfile
touch -t ${2}0000 endfile
find . -type f -name "CD*_3.12.GZ" -newer startfile ! -newer endfile -exec scp -p {} smlaem@smlpkg1.at.inside:${DESTINATION} \;
ssh smlaem@smlpkg1.at.inside "gunzip ${DESTINATION}/CD*_3.12.GZ"

scp -p trt3.sh trt2.sh smlaem@smlpkg1.at.inside:${DESTINATION}
ssh smlaem@smlpkg1.at.inside "cd ${DESTINATION}; ./trt3.sh"
ssh smlaem@smlpkg1.at.inside "cd ${DESTINATION}; ./trt2.sh"
COUNT=$(ssh smlaem@smlpkg1.at.inside "find ${DESTINATION} -type f -name "*.fin" | wc -l")
echo "Remaining FIN files: ${COUNT}"
while [ ${COUNT} -gt 0 ]
	do
		echo "Sleeping .."; sleep 30
		COUNT=$(ssh smlaem@smlpkg1.at.inside "find ${DESTINATION} -type f -name "*.fin" | wc -l")
		echo "Remaining FIN files: ${COUNT}"
	done
rm startfile
rm endfile