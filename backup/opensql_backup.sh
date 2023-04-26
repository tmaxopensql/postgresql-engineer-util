#!/bin/bash
PATH=/usr/pgsql-14/bin/:$PATH
DATETIME=`date +%Y%m%d_%H%M%S`
CON_CHK_FLAG="t"

# LOGGING
function logging() {
	LOGDATE=`date +%Y-%m-%d\ %H:%M:%S`
	echo -e "[$LOGDATE] $1"
        if [[ $BAK_LOG_ENABLE =~ [Yy] ]]; then
                echo -e "[$LOGDATE] $1" >> ${BAK_LOG_DIR}/backup-${DATETIME}.log;
        fi
}

function get_DB_info() {
logging "Exec get_DB_info()..."
    sizeSum=0
                logging "\n| Database List "
                logging "-----------------"
    shopt -s lastpipe
    psql -q --host=${CON_HOST} --port=${CON_PORT} --username=${CON_USER} -x -A -l | grep Name | while read line
    do
        psql -q --host=${CON_HOST} --port=${CON_PORT} --username=${CON_USER} -xAtc "SELECT pg_database_size('${line:5}') AS size" | read size
                logging "| ${line:5} "$((${size:5}/1024/1024))"MB"
        sizeSum=$((${sizeSum} + ${size:5}))
    done
                logging "Total Database Size : "$((${sizeSum}/1024/1024))"MB"

}

function print_Progress() {
	touch ~/.progress.lock
	sleep $1
	while [[ -f ~/.progress.lock ]]; 
	do
		PROGRESS=`psql -h ${CON_HOST} -p ${CON_PORT} -U ${CON_USER} -c "SELECT bak_info.total||'MB' as TOTAL_BACKUP_SIZE, bak_info.now||'MB' AS RECEIVED_SIZE, bak_info.tbs_total AS TOTAL_TABLESPACE_COUNT, bak_info.tbs_now AS RECEIVED_TABLESPACE_COUNT, (bak_info.now*100/bak_info.total)||'%' AS PROGRESS FROM (SELECT CASE backup_total WHEN NULL THEN 0 ELSE backup_total/1024/1024 END AS total, CASE backup_streamed WHEN NULL THEN 0 ELSE backup_streamed/1024/1024 END AS now, CASE tablespaces_total WHEN NULL THEN 0 ELSE tablespaces_total END AS tbs_total, CASE tablespaces_streamed WHEN NULL THEN 0 ELSE tablespaces_streamed END AS tbs_now FROM pg_stat_progress_basebackup)as bak_info"`
		logging "\n$PROGRESS"
	sleep $1
	done
}

function calculate_Time() {
	elapse_time=`echo "$2-$1" | bc`
	hour_e=`echo "$elapse_time/3600" | bc`
	min_e=`echo "$elapse_time/60%60" | bc`
	sec_e=`echo "$elapse_time%60" | bc`
	logging "elapsed time for backup = ${hour_e}h : ${min_e}m : ${sec_e}s"
}

# 2022-12-08 
function tablespace_remapping() {
logging "Exec tablespace_remapping()..."
        LOCS=`psql -q --host=${CON_HOST} --port=${CON_PORT} --username=${CON_USER} -x -A -t -c "\db+"`
        logging "Tablespace info :"
	echo -e "Tablespace info :\n" >> ${BAK_LOG_DIR}/tbs_remap_info
	`psql -q --host=${CON_HOST} --port=${CON_PORT} --username=${CON_USER} -x -A -t -c "SELECT oid as SymboliclinkName, spcname as TablespaceName FROM pg_catalog.pg_tablespace" >> ${BAK_LOG_DIR}/tbs_remap_info` 
	logging "\n$LOCS"
	echo ${BAK_DIR}/tbs_remap/tbs_remap_info
	echo -e "\n$LOCS" >> ${BAK_LOG_DIR}/tbs_remap_info
        LOCS=($(echo "$LOCS" | grep Location | tr ' ' '\n'))

        for((i=0; i<${#LOCS[@]};i++)); do
                LOCATION="${LOCS[$i]//*|/}"

                if [[ ! ${#LOCATION} -lt 1 ]]; then
                        #logging "$LOCATION REMAPPED TO ${BAK_DIR}/tbs_remap/$LOCATION"
                        BAK_OPTS="$BAK_OPTS --tablespace-mapping=$LOCATION=${BAK_DIR}/tbs_remap/$LOCATION"
                fi
        done
}

# CACLUATE PERIOD
function calPeriod() {
# $1 = period
case $1 in
        1) echo "0 0 * * * " ;;
        2) echo "0 0 * * 7 " ;;
        3) echo "0 0 1 * * " ;;
esac
}

# EDIT CRONTABLE & INSTALL
function editCron() {
logging "Exec editCron()..."
        crontab -l > ${BAK_DIR}/crontmpf
logging "Exec calPeriod()..."
        CRON_CMD=$(calPeriod $1)
        CRON_CMD="$CRON_CMD $2"
	sed -i "/opensql_backup/d" ${BAK_DIR}/crontmpf
        echo "$CRON_CMD" >> ${BAK_DIR}/crontmpf
        crontab -r
        crontab -i ${BAK_DIR}/crontmpf
        logging "$CRON_CMD"
        rm -rf ${BAK_DIR}
}

# 2023-03-01
function checkHost() {
if [[ ${CON_TYPE} =~ [pP] ]] || [[ ${CON_TYPE} =~ [sS] ]]; then
        for PHOST in ${CON_HOST[@]};
        do
            RECV_MODE=`psql -q -h ${PHOST} -p ${CON_PORT} -U ${CON_USER} -A -t -c "SELECT pg_is_in_recovery()"`
		CON_CHK_FLAG="t"
		if [[ ${CON_TYPE} =~ [pP] ]] && [[ $RECV_MODE == f ]]; then
		    CON_HOST=${PHOST}
		elif [[ ${CON_TYPE} =~ [sS] ]] && [[ $RECV_MODE == t ]]; then	
		    CON_HOST=${PHOST}
		else
		    CON_CHK_FLAG="f"
		fi
        done
elif [[ ${CON_TYPE} =~ [lL] ]]; then
	RECV_MODE=`psql -q -h ${CON_HOST} -p ${CON_PORT} -U ${CON_USER} -A -t -c "SELECT pg_is_in_recovery()"`
	CON_CHK_FLAG="t"
        if  [[ $RECV_MODE != f ]]; then
                    CON_CHK_FLAG="f"
        fi

fi
}

function checkBackup() {
	BACKUP_PROGRESS=`psql -q -h ${CON_HOST} -p ${CON_PORT} -A -t -c "SELECT * FROM pg_stat_progress_basebackup"`
	if [[ ${BACKUP_PROGRESS} != "" ]]; then
		logging "Another backup is in progress..."
		exit 4
        fi
}
# ECHO USAGE
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "Usage: $0 <CONFIG FILE> [OPTION]"
        exit 1
fi

CONFIG_PATH="$1"
SHELL_PATH="$0"
# GET CONFIGURATION
if [[ -e ${1} ]] && [[ -s ${1} ]] ; then
        if [[ ${1:0:1} == . ]] && [[ ! ${1:0:1} == / ]]; then
                CRD=`pwd`
                . $CRD/${1}
                CONFIG_PATH="$CRD/${1}"
        elif [[ ! ${1} == */* ]]; then
                . ./${1}
                CRD=`pwd`
                CONFIG_PATH="$CRD/${1}"
        else
                . ${1}
        fi
else
        echo "[ERR:00] : Configuration file does not exist."
        exit 1
fi

if [[ $# = 2 ]]; then
        case $2 in
                --immediately)
                        BAK_PERIOD=0 ;;
                --getinfo)
                        get_DB_info
                        exit 0 ;;
        esac
fi



# GET SHELL LOCATION
if [[ ! ${0:0:1} == . ]]; then
        SHELL_PATH=$0
elif [[ ! ${0} == */* ]]; then
        SHELL_PATH=$CRD/${0:1}
else
        SHELL_PATH=$CRD/${0:1}
fi

# SET LOG
if [[ ${BAK_LOG_ENABLE} =~ [Yy] ]] ; then
	if [ ! -d ${BAK_LOG_DIR} ]; then 
		mkdir -p ${BAK_LOG_DIR} 
	fi
        touch ${BAK_LOG_DIR}/checkfile
        if [[ ! -d ${BAK_LOG_DIR} ]] || [[ ! -w ${BAK_LOG_DIR}/checkfile ]]; then
                echo "Please Check Log directory... Ex) Permission"
                exit 1
        else
                rm -f ${BAK_LOG_DIR}/checkfile
                BAK_OPTS="$BAK_OPTS --verbose "
        fi
fi

echo -e ""
echo -e "Configuration file path : $1"
echo -e "Start logging..."
echo -e "Log file : ${BAK_LOG_DIR}/backup-${DATETIME}.log"

# CHECK & SET BAK_DIR
logging "CHECK & SET BAK_DIR..."
if [ ! -d ${BAK_DIR} ]; then 
	mkdir -p ${BAK_DIR} 
fi

touch ${BAK_DIR}/checkfile
if [[ ! -d ${BAK_DIR} ]] || [[ ! -w ${BAK_DIR}/checkfile ]]; then
                logging "[ERR:01] : Please Check Backup directory... Ex) Permission"
                exit 1
else
                rm -f ${BAK_DIR}/checkfile
                BAK_DIR=${BAK_DIR}/backup-${DATETIME}
                mkdir ${BAK_DIR}
                BAK_OPTS="${BAK_OPTS} -D ${BAK_DIR}"
fi


# SET CONNECTION
logging "SET CONNECTION..."
if [[ ! ${CON_TYPE} =~ [pP] ]] && [[ ! ${CON_TYPE} =~ [sS] ]] && [[ ! ${CON_TYPE} =~ [lL] ]]; then
        logging "[ERR:03] : Please, Input valid connection information in configuration file"
        exit 3;
fi

checkHost

if [[ ${CON_CHK_FLAG} == "f" ]] && [[ ${CON_RETRY_COUNT} != "" ]] && [[ ${CON_RETRY_COUNT} -gt 1 ]]; then
        CON_CHK_COUNT=0
        while [[ ${CON_CHK_COUNT} -le ${CON_RETRY_COUNT} ]] && [[ ${CON_CHK_FLAG} == "f" ]];
        do
                if [[ $CON_RETRY_TIME != "" ]] && [[ ${CON_RETRY_TIME} -ge 0 ]]; then
                        sleep ${CON_RETRY_TIME}
                else
                        sleep 10
                fi
                checkHost
                CON_CHK_COUNT=$((CON_CHK_COUNT+1))
        done
fi

if [[ ${CON_CHK_FLAG} == "f" ]]; then
        logging "[ERR:04] : Please, check connection to host"
        exit 4;
fi
BAK_OPTS="-h ${CON_HOST} -p ${CON_PORT} -U ${CON_USER} $BAK_OPTS"


# SET PERIOD
logging "SET PERIOD..."
if [[ ! $BAK_PERIOD =~ ^[0-3] ]] || [[ ${#BAK_PERIOD} -gt 1 ]]; then
        logging "[ERR:02] : Please, Input valid period in configuration file"
        exit 2
fi


# SET COMPRESS
logging "SET COMPRESS..."
if [[ ${#BAK_COMPRESS_LEVEL} -gt 0 ]] && [[ ${BAK_COMPRESS_ENABLE} == Y ]] || [[ ${BAK_COMPRESS_ENABLE} == y ]]; then
        BAK_OPTS="$BAK_OPTS -Ft --compress=$BAK_COMPRESS_LEVEL "
else
        tablespace_remapping
fi

# SET CHECKPOINT
logging "SET CHECKPOINT..."
if [[ ${BAK_CHECKPOINT_FAST} =~ [yY] ]] ; then
        BAK_OPTS="$BAK_OPTS --checkpoint=fast "
fi

# SET SYNC
logging "SET SYNC..."
if [[ ${BAK_ASYNC} =~ [yY] ]] ; then
        BAK_OPTS="$BAK_OPTS --no-sync "
fi

# SET CHECK_PROGRESS_TIME
if [[ ${BAK_CHECK_PROGRESS_ENABLE} =~ [yY] ]] && [[ ! ${BAK_CHECK_PROGRESS_TIME} =~ ^[1-9]$|^[1-9]{1}[0-9]$ ]]; then
	logging "[ERR:05] BAK_CHECK_PROGRESS_TIME is not decimal value OR out of range!!"
	exit 05
fi

# SET MAX_RATE
logging "SET MAX_RATE..."
if [[ ${MAX_RATE} != "" ]] ; then
        BAK_OPTS="$BAK_OPTS --max-rate=${MAX_RATE} "
fi

# SET LABEL
logging "SET LABEL"
BAK_OPTS="$BAK_OPTS --label=${DATETIME}"

logging "$BAK_OPTS"
# BACKUP DATABASE CLUSTER

logging "SETUP CONFIGURATION COMPLETE..."
logging "CHECKING ANOTHER BACKUP IS ON PROGRESS..."
checkBackup
logging "START BACKUP..."
get_DB_info

case $BAK_PERIOD in
        0) 	start_time=`date +%s`
		if [[ ${BAK_CHECK_PROGRESS_ENABLE} =~ [yY] ]]; then 
			logging "SET CHECK_PROGRESS OF BACKUP"
			print_Progress ${BAK_CHECK_PROGRESS_TIME} &
		fi
		pg_basebackup ${BAK_OPTS} >> ${BAK_LOG_DIR}/backup-${DATETIME}.log 2>&1
		if [[ $? -eq 0 ]]; then
                	logging "BACKUP COMPLETE.." 
			if [[ -f ${BAK_LOG_DIR}/tbs_remap_info ]]; then	
				mv ${BAK_LOG_DIR}/tbs_remap_info ${BAK_DIR}/tbs_remap_info
				if [[ -d ${BAK_DIR}/pg_tblspc ]] && [[ ! -e ${BAK_DIR}/pg_tblspc ]]; then
					rm ${BAK_DIR}/pg_tblspc/*
				fi
			fi
		else
                	logging "BACKUP FAILED..\nPLEASE SEE LOGS..." 
		fi
         	if [[ ${BAK_CHECK_PROGRESS_ENABLE} =~ [yY] ]] && [[ -f ~/.progress.lock ]]; then 
			rm ~/.progress.lock
		fi
		end_time=`date +%s`
		calculate_Time $start_time $end_time
		;;
        *) editCron $BAK_PERIOD "$SHELL_PATH $CONFIG_PATH --immediately"
                logging "BACKUP RESERVED.." ;;
esac
