#!/usr/bin/ksh
for F in $(find . -type f -name "*_T$1*")
	do
        echo ${F}
        F1=$(echo "${F}" | awk -F '.' '{print "."$2".FIN"}')
        TS=$(/usr/local/bin/perl -MPOSIX=strftime -le 'print strftime("%Y%m%d%H%M.%S", localtime((stat shift)[9]))' ${F})
        echo "Doing File \"${F1}\" with TS=\"${TS}\""
        touch -t ${TS} ${F1}
	done 