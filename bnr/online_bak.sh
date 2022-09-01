#/bin/bash

#############################
# USAGE
# /bin/bash online_bak.sh bakupFileName
#############################

baseDir=/hypersql/pg/$PGVERSION
bakinfo=${baseDir}/online_backup.info
function get_DB_info() {
    sizeSum=0
    		echo -e "\n| Database List " >> ${bakinfo}
    		echo "-----------------" >> ${bakinfo}
    shopt -s lastpipe
    psql -x -A -l | grep Name | while read line
    do
        psql -xAtc "SELECT pg_database_size('${line:5}') AS size" | read size
        	echo "| ${line:5} "$((${size:5}/1024/1024))"MB" >> ${bakinfo}
        sizeSum=$((${sizeSum} + ${size:5}))
    done
    		echo "Total Database Size : "$((${sizeSum}/1024/1024))"MB" >> ${bakinfo}
}

function online_bak(){
    		echo -e "\nBackup lable : ${1}" >> ${bakinfo}
    bakName=${1}"-"$(date '+%Y%m%d-%H%M%S')
    timeNow=$(date '+%Y-%m-%d %H:%M:%S')
    psql -c "SELECT pg_start_backup('${1}')" >> ${bakinfo}
    tar czfP "${baseDir}/${bakName}.tar.gz" ${baseDir}/data
    psql -c "SELECT pg_stop_backup()" >> ${bakinfo}
    timeNow=$(date '+%Y-%m-%d %H:%M:%S')
		echo "${timeNow} BACKUP FINISHED" | tee -a ${bakinfo}
    tarSize=`du -h ${baseDir}/${bakName}.tar.gz`
		echo -e "Backup file : ${tarSize}" >> ${bakinfo}
}

function Main(){
    		echo "===== Making online_backup.info ====="
		echo "===== ${bakinfo} ====="
    get_DB_info
    		echo "=====           Done           ====="
    		echo "=====       Backup Start       ====="
    if [[ -z "$1" ]]; then
        bakName="online_backup"
    else
        bakName="$1"
    fi
    online_bak ${bakName}
    		echo "=====      Backup Finished     ====="
}

Main $1
