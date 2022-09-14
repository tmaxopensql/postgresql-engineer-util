#!/bin/sh

# WAL file name의 타임 라인 값 감소 시키기
function front_counter(){
  fresult=`echo "obase=10; ibase=16; $1" | bc`
  fresult=$((fresult-$2)) 
  fresult=`echo "obase=16; ibase=10; $fresult" | bc` 

  count=$((8-${#fresult}))
  for((i=1; i<=${count}; i=i+1)); do
    fresult="0${fresult}"
  done
  echo "${fresult}"
}

# WAL file name의 중간 값 감소 시키기
function middle_counter(){
  operMid=${1:8:8}
  operFront=${1:0:8}
  mresult=`echo "obase=10; ibase=16; $operMid" | bc`
  mresult=$((mresult-$2))
  multiple=0  

  if [[ $mresult -lt 0 ]]; then
    mresult=${mresult#-}
    multiple=$((${mresult}/256+1))    
    if [[ $(($mresult%256)) -eq 0 ]]; then
      mresult=0
    else
      mresult=$((256-$mresult%256))
    fi    
  fi
  fresult=$(front_counter $operFront $multiple)
  mresult=`echo "obase=16; ibase=10; $mresult" | bc`
  count=$((8-${#mresult}))
  for((i=1; i<=${count}; i=i+1)); do
    mresult="0${mresult}"
  done
  echo "${fresult}${mresult}"

}

# WAL file name의 마지막값 감소 시키기

function end_counter(){
  eresult=`echo "obase=10; ibase=16; ${1:(-8)}" | bc`
  eresult=$(($eresult-$2))
  multiple=0
  
  if [[ $eresult -lt 0 ]]; then
    eresult=${eresult#-}
    multiple=$((${eresult}/256+1))
    if [[ $(($eresult%256)) -eq 0 ]]; then
      eresult=0  
    else
      eresult=$((256-$eresult%256))
    fi
  fi
  mresult=$(middle_counter $1 $multiple)
  eresult=`echo "obase=16; ibase=10; $eresult" | bc`
  
  # for문으로 0 붙여주기
  count=$((8-${#eresult}))
  for((i=1; i<=${count}; i=i+1)); do
    eresult="0${eresult}"
  done
  echo "${mresult}${eresult}"
}

function get_archive(){
  archive_dir=`psql -t -c "SHOW archive_command"`

  archive_dir=${archive_dir//\"/}
  archive_dir=${archive_dir//cp/}
  if [[ $archive_dir == *&&* ]]; then
    archive_dir=${archive_dir/*&&/}
  fi
  archive_dir=${archive_dir/\/%f/}
  archive_dir=${archive_dir/ %p/}

  echo "$archive_dir"
}


function walReader(){
  echo "Start read WAL files from ${3}"

  words=("COMMIT" "CHECKPOINT" "VACUUM" "RESTORE")

  for((i=0; i<=1000; i=i+1)); do
    nextWalName=$(end_counter ${2} $i)
    if [[ "$nextWalName" == "${4}" ]]; then
      break;
    fi
    echo "Reading .. ${nextWalName}"
  #읽어올 WAL 파일명${nextWalName}"
    grepWord=""
    for((j=0; j<${#words[@]};j=j+1)); do
      if [[ ${#words[@]} -eq $((j-1)) ]] || [[ $j -eq 0 ]] ;then
        grepWord="${grepWord}${words[$j]}"
      else
        grepWord="${grepWord}|${words[$j]}"
      fi
    done
    waldump=`pg_waldump ${3}/${nextWalName} 2>>error.log | grep -E "$grepWord" >> wal.txt`
  done

  echo -e "Finished to read WAL files from ${3}\n"
}

#####################################################
#####################################################

echo "PITR needs backup"
echo "Please, Input your backup data directory"
echo "Ex) /hypersql/bak/2022-12-31/data/"

read bakDir
if [[ ${#bakDir} -lt 0 ]] || [[ ! -d ${bakDir} ]]; then
  echo "You inputed wrong directory!!"
  exit 100
fi

bakDir="$bakDir/"

arcvDir=$(get_archive)
arcvDir=($(echo "$arcvDir" | tr ' ' '\n'))

priorChk=`pg_controldata $bakDir | grep 'WAL file'`
priorChk=${priorChk/Latest checkpoint\'s REDO WAL file:}
priorChk=($(echo "$priorChk" | tr ' ' '\n'))

echo "$priorChk"

lastChk=`pg_controldata | grep 'WAL file'`
lastChk=${lastChk/Latest checkpoint\'s REDO WAL file:}
lastChk=($(echo "$lastChk" | tr ' ' '\n'))

wal_size=`cat ${PGDATA}/postgresql.conf | grep max_wal_size | grep -v "#"`
wal_size=${wal_size//[mxwalsize=_]/}
wal_size=($(echo "$wal_size" | tr ' ' '\n'))

walCount=0

# max_wal_size의용량 타입에 따른 조건분기
if [[ $wal_size == *GB* ]]; then
  walCount=$((${wal_size//[GB]/}*1024/16))
elif [[ $wal_size == *MB* ]]; then
  walCount=$((${wal_size//[MB]/}/16))
fi

# wal.txt 삭제

if [[ -f wal.txt ]]; then
  rm wal.txt
fi

# wal 읽어오기
walReader ${walCount} ${lastChk} ${PGDATA}/pg_wal ${priorChk}
walReader ${walCount} ${lastChk} ${arcvDir} ${priorChk}

# Recovery Target 입력받기
targetType=("lsn" "xid" "time" "timeline" "name")
  echo -e "Please choose number of target what you want to recovery \n"
for((i=0; i<${#targetType[@]}; i=i+1)); do
  echo "$((i+1)).${targetType[i]}"
done
  echo -e ""

read selType
selType=$(($selType-1))
if [[ ${selType} -lt 0 ]]; then
  selType=3
fi

# 입력 받은 Recovery Target을 기준으로Recovery가 가능한 시점만 읽어옴
while read line || [ -n "$line" ]; do
  #echo "$line" | grep ${targetType[$selType]}
  echo "$line"
done < wal.txt


# 해당Recovery target을 어떤값으로 설정할지 입력받음
echo -e "\nPlease Input your target ${targetType[$selType]}"
read targetValue

if [[ ${#targetValue} -lt 0 ]]; then
  targetValue="latest"
fi

#mod2는 postgresql.auto.conf에 해당 recovery 내용을 넣어주는 script 
./mod2_autoconf.sh restore_command "cp ${arcvDir}/%f %p" 1 ${bakDir}
./mod2_autoconf.sh recovery_target_${targetType[$selType]} ${targetValue} 0 ${bakDir}
./mod2_autoconf.sh recovery_target_action promote 0 ${bakDir}
