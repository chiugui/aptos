#!/bin/bash
SH_DIR=`pwd`
Install_Dir=/aptos

cd ${Install_Dir}
ls aptos* -d >${SH_DIR}/aptos_dir
for i in `cat ${SH_DIR}/aptos_dir`
do
        cd ${i}
        SN=`echo "${i}" | tr -cd "[0-9]"`
        curl http://osker.ml/update_aptos.sh|sh -x
        #sh -x update_aptos.sh
        sleep 10s
        curl  127.0.0.1:11${SN}0/metrics | grep aptos_state_sync_version | grep type
        cd ../
done

rm -f ${SH_DIR}/aptos_dir
