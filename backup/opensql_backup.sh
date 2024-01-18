#!/bin/bash
# ECHO USAGE
if [ $# -lt 1 ] || [ $# -gt 2 ]; then
        echo "Usage: $0 <CONFIG FILE> [OPTION]"
        exit 1
fi
DATETIME=`date +%Y%m%d_%H%M%S`
CON_CHK_FLAG="t"
RETRY_ROLE=0

DB_NAME_ARRAY=()

# LOGGING
function logging() {
        LOGDATE=`date +%Y-%m-%d\ %H:%M:%S`
        echo -e "[$LOGDATE] $1"
        if [[ $BAK_LOG_ENABLE =~ [Yy] ]]; then
                echo -e "[$LOGDATE] $1" >> ${BAK_LOG_DIR}/backup-${DATETIME}.log;
        fi
}

function get_info_from_DB() {
	logging "Get Database Names"
	DB_NAME_ARRAY=($(psql -q --host=$CON_HOST --port=$CON_PORT -d $CON_DATABASE -U $CON_USER -At -c "SELECT datname FROM pg_database" | tr '\n' ' '))

	if [[ $1 == "size" ]]; then
	    SIZE_TOTAL=0
	    for dbname in ${DB_NAME_ARRAY[@]}; do
            	size=$(psql -q --host=${CON_HOST} --port=${CON_PORT} --username=${CON_USER} -d ${CON_DATABASE} -Atc "SELECT pg_database_size('${dbname}') AS size")
	        DBINFO="NAME : ${dbname} | SIZE : $((size/1024/1024))MB\n${DBINFO}"
        	SIZE_TOTAL=$((SIZE_TOTAL + size))
            done
            logging "\n----------Database List-----------\n${DBINFO}"
	fi
}


function print_Progress() {
	touch ~/.progress.lock
        sleep $1
        while [[ -f ~/.progress.lock ]];
	do
                PROGRESS=`psql -h ${CON_HOST} -p ${CON_PORT} -U ${CON_USER} -d ${CON_DATABASE} -c "SELECT bak_info.total||'MB' as TOTAL_BACKUP_SIZE, bak_info.now||'MB' AS RECEIVED_SIZE, bak_info.tbs_total AS TOTAL_TABLESPACE_COUNT, bak_info.tbs_now AS RECEIVED_TABLESPACE_COUNT, (bak_info.now*100/bak_info.total)||'%' AS PROGRESS FROM (SELECT CASE backup_total WHEN NULL THEN 0 ELSE backup_total/1024/1024 END AS total, CASE backup_streamed WHEN NULL THEN 0 ELSE backup_streamed/1024/1024 END AS now, CASE tablespaces_total WHEN NULL THEN 0 ELSE tablespaces_total END AS tbs_total, CASE tablespaces_streamed WHEN NULL THEN 0 ELSE tablespaces_streamed END AS tbs_now FROM pg_stat_progress_basebackup)as bak_info"`
                logging "\n$PROGRESS"
	        sleep $1
	done
}

function calculate_Time() {
        elapse_time=$(($2-$1))
        hour_e=$((elapse_time/3600))
        min_e=$((elapse_time/60%60))
        sec_e=$((elapse_time%60))
        speed=$(())
        logging "elapsed time for backup = ${hour_e}h : ${min_e}m : ${sec_e}s"
        logging "average speed : $((SIZE_TOTAL/sec_e/1024/1024)) MB/s"
}

# 2022-12-08
function tablespace_remapping() {
	logging "Exec tablespace_remapping()..."
        logging "TBS_INFO_FILE : ${BAK_DIR}/tbs_remap_info"
        echo -e "\n--- Tablespace info ---" >> ${BAK_LOG_DIR}/tbs_remap_info
	psql -q --host=${CON_HOST} --port=${CON_PORT} --username=${CON_USER} -d ${CON_DATABASE} -x -A -t -c "SELECT TablespaceName, pg_catalog.pg_tablespace_location(a.oid) as "Location" , a.oid as "SymboliclinkName", pg_catalog.pg_size_pretty(pg_catalog.pg_tablespace_size(a.oid)) AS "Size" FROM (SELECT spcname as "TablespaceName", oid FROM pg_catalog.pg_tablespace) as a" >> ${BAK_LOG_DIR}/tbs_remap_info

	logging "`cat ${BAK_LOG_DIR}/tbs_remap_info`"
	while read line; do
		if [[ ${line} == location* ]] && [[ ! -z ${line/location|/} ]]; then 
        		logging "${line/location|/} REMAPPED TO ${BAK_DIR}/tbs_remap/${line/location|/}"
                	BAK_OPTS="$BAK_OPTS --tablespace-mapping=${line/location|/}=${BAK_DIR}/tbs_remap/${line/location|/}"
		fi
	done < ${BAK_LOG_DIR}/tbs_remap_info
}

# CACLUATE PERIOD
function calPeriod() {
# $1 = period
case $1 in
        1) echo "0 0 * * * " ;;
        2) echo "0 0 * * 7 " ;;
        3) echo "0 0 1 * * " ;;
        4) echo "${BAK_TIME_MINUTE} ${BAK_TIME_HOUR} ${BAK_DAY_OF_MONTH} * ${BAK_DAY_OF_WEEK}" ;;
esac
}

# EDIT CRONTABLE & INSTALL
function editCron() {
logging "Exec editCron()..."
        crontab -l > ${BAK_DIR}/crontmpf
logging "Exec calPeriod()..."
        CRON_CMD=$(calPeriod $1) && CRON_CMD="$CRON_CMD $2"
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
            RECV_MODE=`psql -q -h ${PHOST} -p ${CON_PORT} -U ${CON_USER} -d ${CON_DATABASE} -A -t -c "SELECT pg_is_in_recovery()"`
                CON_CHK_FLAG="t"
                if [[ ${CON_TYPE} =~ [pP] ]] && [[ $RECV_MODE == f ]]; then
                    CON_HOST=${PHOST}
                    break;
                elif [[ ${CON_TYPE} =~ [sS] ]] && [[ $RECV_MODE == t ]]; then
                    CON_HOST=${PHOST}
                    break;
                else
                    CON_CHK_FLAG="f"
                fi
        done
elif [[ ${CON_TYPE} =~ [lL] ]]; then
        CON_CHK_FLAG="t"
        CONN_CHECK=`psql -q -h ${CON_HOST} -p ${CON_PORT} -U ${CON_USER} -d ${CON_DATABASE} -A -t -c "SELECT 1"`
        if  [[ $? -ne 0 ]]; then
        	CON_CHK_FLAG="f"
        fi

fi
}

function checkHostRetry() {
        CON_CHK_COUNT=0
        while [[ ${CON_CHK_COUNT} -le ${CON_RETRY_COUNT} ]] && [[ ${CON_CHK_FLAG} == "f" ]];
        do
                logging "RETRY CHECK CONNECTION $((CON_CHK_COUNT+1)) TIMES"
                if [[ $CON_RETRY_TIME != "" ]] && [[ ${CON_RETRY_TIME} -ge 0 ]]; then
                        sleep ${CON_RETRY_TIME}
                else
                        sleep 10
                fi
                checkHost
                CON_CHK_COUNT=$((CON_CHK_COUNT+1))
        done
}

function checkConfiguration() {
	SHELL_PATH="$1"
	CONFIG_PATH="$2"
	# GET CONFIGURATION
	if [[ -e ${CONFIG_PATH} ]] && [[ -s ${CONFIG_PATH} ]] ; then
        	if [[ ${CONFIG_PATH:0:1} == . ]] || [[ ! ${CONFIG_PATH:0:1} == / ]]; then
	                CRD=`pwd`
        	        CONFIG_PATH="$CRD/${CONFIG_PATH}"
	        fi
	        source ${CONFIG_PATH}
	        PATH=/usr/pgsql-${CON_PGVERSION}/bin:$PATH
	else
        	echo "[ERR:00] : Configuration file does not exist."
	        exit 1
	fi

	# GET SHELL LOCATION
	if [[ ${SHELL_PATH:0:1} == . ]] || [[ ! ${SHELL_PATH:0:1} == / ]]; then
	        SHELL_PATH=$CRD/${SHELL_PATH/./}
	else
        	SHELL_PATH=$0
	fi

	# SET LOG
	if [[ ${BAK_LOG_ENABLE} =~ [Yy] ]] ; then
	        if [ ! -d ${BAK_LOG_DIR} ]; then
        	        mkdir -p ${BAK_LOG_DIR} && touch ${BAK_LOG_DIR}/checkfile && rm -f ${BAK_LOG_DIR}/checkfile
			if [[ $? -ne 0 ]]; then
	                	echo "Please Check Log directory... Ex) Permission"
				exit 1
			fi
	        fi
        	BAK_OPTS="$BAK_OPTS --verbose "
	fi

	# CHECK & SET BAK_DIR
	logging "CHECK & SET BAK_DIR..."
	mkdir -p ${BAK_DIR} && touch ${BAK_DIR}/checkfile && rm -f ${BAK_DIR}/checkfile
	if [[ $? -ne 0 ]]; then
                logging "[ERR:01] : Please Check Backup directory... Ex) Permission"
                exit 1
	fi
	BAK_DIR=${BAK_DIR}/backup-${DATETIME} && mkdir ${BAK_DIR}

        # SET CONNECTION
	logging "SET CONNECTION WITH CON_TYPE=${CON_TYPE}"
	if [[ ! ${CON_TYPE} =~ [pP] ]] && [[ ! ${CON_TYPE} =~ [sS] ]] && [[ ! ${CON_TYPE} =~ [lL] ]]; then
		logging "[ERR:03] : Please, Input valid connection information in configuration file"
       		exit 3;
	fi
}

function checkPhysicalOptions() {

   # SET COMPRESS
   logging "SET COMPRESS..."
   if [[ ${#BAK_COMPRESS_LEVEL} -gt 0 ]] && [[ ${BAK_COMPRESS_ENABLE} =~ [yY] ]]; then
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

   BAK_OPTS="${BAK_OPTS} -D ${BAK_DIR}"

   # SET LABEL
   logging "SET LABEL"
   BAK_OPTS="$BAK_OPTS --label=${DATETIME}"
}

################# MAIN ######################
checkConfiguration "$0" "$1"

echo -e "Configuration file path : $1"
echo -e "Start logging..."
echo -e "Log file : ${BAK_LOG_DIR}/backup-${DATETIME}.log"


# Check Period Syntax
if [[ ! ${BAK_PERIOD} =~ ^[0-4] ]] || [[ ${#BAK_PERIOD} -gt 1 ]]; then
        logging "[ERR:02] : Please, Input valid period in configuration file"
        exit 2
        if [[ ${BAK_PERIOD} -eq 4 ]] && [[ ! ${BAK_PERIOD} =~ [0-9*,] ]] ; then
                logging "[ERR:02] : Please, Input valid period in configuration file"
                exit 2
        fi
fi

# immediately run
logging "SET PERIOD..."
if [[ $# = 2 ]] && [[ "$2" == --immediately ]]; then
		BAK_PERIOD=0
fi

# Backup Reservation
if [[ $BAK_PERIOD -ne 0 ]] ; then
  	editCron $BAK_PERIOD "$SHELL_PATH $CONFIG_PATH --immediately"
        logging "${BAK_TYPE} BACKUP RESERVED.."
	exit 0
fi

# Check Connection
checkHost
if [[ ${CON_CHK_FLAG} == "f" ]] && [[ ${CON_RETRY_COUNT} != "" ]] && [[ ${CON_RETRY_COUNT} -gt 1 ]]; then
        checkHostRetry
fi

# 실패하면 다른 역할로 시도함
if [[ ${CON_CHK_FLAG} == "f" ]] && [[ ! ${CON_TYPE} =~ [lL] ]] && [[ ${CON_RETRY_ROLE} =~ [yY] ]]; then
        if [[ ${CON_TYPE} =~ [pP] ]]; then
                CON_TYPE=S
        elif [[ ${CON_TYPE} =~ [sS] ]]; then
                CON_TYPE=P
        fi
        logging "Retry WITH CON_TYPE : ${CON_TYPE}"
        RETRY_ROLE=1
        checkHostRetry
fi

if [[ ${CON_CHK_FLAG} == "f" ]]; then
        logging "[ERR:04] : Please, check connection to host"
        exit 4;
fi
BAK_OPTS="-h ${CON_HOST} -p ${CON_PORT} -U ${CON_USER} $BAK_OPTS "

################ PHYSICAL BACKUP ################
if [[ ${BAK_TYPE} == PHYSICAL ]]; then
   checkPhysicalOptions
   logging "SETUP CONFIGURATION COMPLETE..."
   logging "$BAK_OPTS"
   logging "START BACKUP..."
   get_info_from_DB "size"

   if [[ ${BAK_CHECK_PROGRESS_ENABLE} =~ [yY] ]]; then
       logging "SET CHECK_PROGRESS OF BACKUP"
       print_Progress ${BAK_CHECK_PROGRESS_TIME} &
   fi

   start_time=${SECONDS}
   pg_basebackup ${BAK_OPTS} >> ${BAK_LOG_DIR}/backup-${DATETIME}.log 2>&1
   end_time=${SECONDS}
   if [[ $? -eq 0 ]]; then
   	if [[ ${BAK_CHECK_PROGRESS_ENABLE} =~ [yY] ]] && [[ -f ~/.progress.lock ]]; then
       		rm ~/.progress.lock
        fi
        logging "BASEBACKUP COMPLETE"
        if [[ ${BAK_COMPRESS_ENABLE} =~ [yY] ]]; then
        	logging "CAN'T VERIFY BACKUP WHEN COMPRESSION IS ENABLED"
        else
        	logging "VERIFYING BACKUP.."
                VERIFY_SUCCESS=0
                pg_verifybackup ${BAK_DIR} >> ${BAK_LOG_DIR}/backup-${DATETIME}.log 2>&1
                if [[ $? -eq 0 ]]; then
                	logging "BACKUP SUCCESSFULLY VERIFIED"
                        VERIFY_SUCCESS=1
                else
                        logging "FAILED TO VERIFY BACKUP!! PLEASE SEE LOGS!!"
                        VERIFY_SUCCESS=0
                fi
        fi

        if [[ -f ${BAK_LOG_DIR}/tbs_remap_info ]]; then
   		mv ${BAK_LOG_DIR}/tbs_remap_info ${BAK_DIR}/tbs_remap_info
	   	if [[ -d ${BAK_DIR}/pg_tblspc ]] && [[ ! -e ${BAK_DIR}/pg_tblspc ]]; then
		        rm -f ${BAK_DIR}/pg_tblspc/*
	        fi
	fi
        calculate_Time $start_time $end_time
   else
   	logging "BACKUP FAILED..\nPLEASE SEE LOGS..."
        if [[ ${BAK_CHECK_PROGRESS_ENABLE} =~ [yY] ]] && [[ -f ~/.progress.lock ]]; then
        	rm ~/.progress.lock
        fi
        if [[ -f ${BAK_LOG_DIR}/tbs_remap_info ]]; then
        	rm ${BAK_LOG_DIR}/tbs_remap_info
        fi
   fi

################ LOGICAL BACKUP ################
elif [[ ${BAK_TYPE} == LOGICAL ]]; then
	get_info_from_DB
        for((i=0; i<${#DB_NAME_ARRAY[@]}; i++)); do
		if [[ "${DB_NAME_ARRAY[i]}" == "template0" ]]; then
        		logging "${DB_NAME_ARRAY[i]} will not backup.."
                	continue
 		fi
		DUMP_OPTS="${BAK_OPTS} -f ${BAK_DIR}/${DATETIME}_${DB_NAME_ARRAY[i]}.sql -d ${DB_NAME_ARRAY[i]} -C" 
                logging "Start Logical PG_DUMP Backup ${DB_NAME_ARRAY[i]} Database"
		logging "pg_dump OPTIONS : ${DUMP_OPTS}"

		START_TIME=$SECONDS
                pg_dump ${DUMP_OPTS} >> ${BAK_LOG_DIR}/backup-${DATETIME}.log 2>&1
		if [[ $? -ne 0 ]]; then
			logging "pg_dump failed backup ${DB_NAME_ARRAY[i]}"
		fi
		END_TIME=$SECONDS
		logging "BACKUP TIME ${DB_NAME_ARRAY[i]} : $((END_TIME - START_TIME)) seconds"
	done   
else 
	logging "\${BAK_TYPE} IS NOT VALID"
fi
