#!/bin/sh

# ##############################################################
# ARCHIVE_MODE를 반드시 ON 또는 ALWAYS로 설정
# Emergency는 WAL 파일로 복구가 가능한 가장 최근으로 복구를 시도
# Detail은 원하는 시점을 사용자가 직접 입력하도록 함.
# Restore Pint는 WAL에 원하는 복구 시점을 생성함.
# Online Backup은 PGDATA를 FULL BACKUP함.
# mod1_detail.sh은 Detail 입력시 실행되는 쉘
# mod2_autoconf.sh은 Emergency, Detail 입력 내용을 기준으로 
# postgresql.auto.conf를 수정하는쉘
# ##############################################################

function pg_restart(){
  echo -e "\n========   Ready for recovering is done.   ========"
  echo -e "\n======== Do you want to restart HyperSQL?  ========"
  echo -e "\n========  Please Input answer ( y or n )   ========"

  read restartFlag

  if [[ "${restartFlag}" == "y" ]]; then
    pg_ctl restart
  fi
}

type=""

#while [ ${#type} -lt 1 ] || [ $type -gt 2 ] ||  [ $type -lt 1 ]; do
 echo "Select your target"
 echo "1. Emergency recovery  2. Detail recovery  3. Create Restore Point  4. Online Backup"
 read type
#done

case $type in
  1) echo -e "\nEmergency recovery start.."
  ./mod2_autoconf.sh recovery_target immediate 1 2>error.log
  ./mod2_autoconf.sh recovery_target_action pause 2>error.log
  pg_restart;;
  
  2) echo -e "\nUser customized recovery start.."
  ./mod1_detail.sh 
  pg_restart;;

  3) if [[ $(cat $PGDATA/postgresql.conf | grep -v "#" | grep wal_level) == *minimal* ]]; then
       echo -e "\nThis is need to set wal_level to \"replica\" or \"logical\""
       echo "Please change it and try again"
     else
       echo -e "\nInput name what you want to make"
       read name
       psql -c "SELECT pg_create_restore_point('$name')" 2>>error.log
     fi 
     exit 0;;
  
  4) echo -e "Run online_bak.sh\n"
     ./online_bak.sh;;
  *) echo "Input value error"

esac

