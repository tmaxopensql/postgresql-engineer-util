#!/bin/sh

# Usage
# $1 = target / $2 = Value / $3 = resetFlag
# resetFlag 0 : maintain postgresql.auto.conf
# resetFlag 1 : delete about recovery from postgresql.auto.conf
# Ex) recovery_name rp1

# 기존 값 주석 처리 
if [[ "${#3}" -gt 0 && $3 -eq 1 ]]; then
  sed -i "/recovery/d" $PGDATA/postgresql.auto.conf
fi

# Value Insert
echo "SET ${1} = ${2} postgresql.auto.conf"
echo "${1} = '${2}'" >> $PGDATA/postgresql.auto.conf
touch $PGDATA/recovery.signal
