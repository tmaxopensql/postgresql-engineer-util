#!/bin/sh

# Usage
# $1 = target / $2 = Value / $3 = resetFlag
# resetFlag 0 : maintain postgresql.auto.conf
# resetFlag 1 : delete about recovery from postgresql.auto.conf
# Ex) recovery_name rp1

# 기존 값 주석 처리 
if [[ "${#3}" -gt 0 && $3 -eq 1 ]]; then
  if [[ "${#4}" -gt 0 ]]; then
    sed -i "/recovery/d" ${4}/postgresql.auto.conf
    sed -i "/restore/d" ${4}/postgresql.auto.conf
  else
    sed -i "/recovery/d" $PGDATA/postgresql.auto.conf
    sed -i "/restore/d" $PGDATA/postgresql.auto.conf
  fi
fi

# Value Insert
echo "SET ${1} = ${2}"

if [[ "${#4}" -gt 0 ]]; then
  echo "${1} = '${2}'" >> ${4}/postgresql.auto.conf
  touch ${4}/recovery.signal
else
  echo "${1} = '${2}'" >> $PGDATA/postgresql.auto.conf
  touch $PGDATA/recovery.signal
fi
