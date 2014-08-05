#!/usr/bin/ksh
for file in CD*_3.12
        do
                 mv -i "${file}" "${file/_3.12/}"
done