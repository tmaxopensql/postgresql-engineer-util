#!/bin/bash
####################################
##hypersql postgresql 기술지원 shell
## File name : pgcheck.sh
## Modified History
## son young been (ver1.0)
####################################

echo -e ""
echo "##### Start HyperSQL PostgreSql Check Program #####"
echo -e ""

defdb="postgres"
defown="postgres"
defpwd="postgres"

while true
do
echo "Input Database Name : "
read dbname
echo -e ""

result1=$(PGPASSWORD=$defpwd psql -U $defown -d $defdb -v v1="'$dbname'" -f ./sql/dbcheck.sql)

if [[ "$result1" == *0* ]]; then
 	dbname="NULL"
 	echo "##### Not Found Database!! Please Retry #####"
 	echo -e ""
 	echo -e ""
else
 	echo "##### Database Checked #####"
 	echo -e ""
 	echo -e ""
 	break;
fi

done

while true
do
echo "Input Owner Name : "
read owname
echo -e ""

result2=$(PGPASSWORD=$defpwd psql -U $defown -d $defdb -v v1="'$owname'" -f ./sql/usercheck.sql)

if [[ "$result2" == *0* ]]; then
 	owname="NULL"
 	echo "##### Not Found Owner!! Please Retry #####"
 	echo -e ""
else
 	echo "##### Owner Checked #####"
 	echo -e ""
 	echo -e ""
 	break;
fi

done

while true
do
echo "Input Owner Password : "
read -s ownpwd
echo -e ""

result3="NULL"
result3=$(PGPASSWORD=$ownpwd psql -U $owname -d $dbname -c "select version()")

if [[ "$result3" == *PostgreSQL* ]]; then
 	echo "##### Password Checked #####"
 	echo -e ""
 	break;
else
 	echo "##### Password Incorrect!! Please Retry #####"
 	echo -e ""
 	echo -e ""
fi
done

while true
do
read -p "##### Write Result Files? (y/n) ##### input : " ynread

if [ "$ynread" == "y" ] || [ "$ynread" == "Y" ]; then
        flag="y"
	mkdir ./chkreslt/$dbname
        echo "##### File Write Mode On #####"
        break;
else if [ "$ynread" == "n" ] || [ "$ynread" == "N" ]; then
        flag="n"
        echo "##### File Write Mode Off #####"
        break;
else
        echo "##### Choose y/n #####"
        echo -e ""
fi
fi
done


while true
do
echo -e ""

echo -e "##### CURRENT DATABASE is $dbname #####"

echo -e "##### CURRENT OWNER is $owname #####"

if [ "$flag" == "y" ]; then
	echo -e "##### File Write On #####"
else
	echo -e "##### File Write Off #####"
fi

echo -e ""

echo  "##### SELECT CONTENTS #####
0. Version Check
1. Database & Owner Check
2. Conf Check
3. Memory Check
4. Process Check
5. Space Usage Check
6. System Resource and FileSystem Check
7. Disk I/O Check
8. Current Session Check
9. Top 10 Sql Check
10. Vacuum Check
11. Log Check
12. Lock Check
\c. Change Database & Owner
\f. Change File Write mode(flag : $flag)
\q. Exit Program
#############################"

echo "input number : " 
read num
echo -e ""

dirname=${dbname}

case $num in
0)
	rm ./chkreslt/$dirname/0_version.txt
clear

if [ "$flag" == "y" ]; then
	echo -e "##### Version Check #####"
	echo -e "##### Version Check #####" > ./chkreslt/$dirname/0_version.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/0_version.txt
#psql -f /var/lib/pgsql/check/sql/0_version.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/0_version.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/0_version.sql >> ./chkreslt/$dirname/0_version.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/0_version.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

else

	echo -e "##### Version Check #####"
	echo -e ""
#psql -f /var/lib/pgsql/check/sql/0_version.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/0_version.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

fi
;;

1)
	rm ./chkreslt/$dirname/1_dbownerchk.txt
clear

if [ "$flag" == "y" ]; then
	echo -e "##### Database & Owner List Check #####"
	echo -e "##### Database & Owner List Check #####" > ./chkreslt/$dirname/1_dbownerchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/1_dbownerchk.txt
#psql -f /var/lib/pgsql/check/sql/0_dblist.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/1_dblist.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/1_dblist.sql >> ./chkreslt/$dirname/1_dbownerchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/1_dbownerchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

else

	echo -e "##### Database & Owner List Check #####"
	echo -e ""
#psql -f /var/lib/pgsql/check/sql/0_dblist.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/1_dblist.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

fi
;;

2)
	rm ./chkreslt/$dirname/2_confchk.txt

clear

if [ "$flag" == "y" ]; then
	echo -e "##### Archive Setting Check #####"
	echo -e "##### Archive Setting Check #####" > ./chkreslt/$dirname/2_confchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/2_confchk.txt 
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/2_archchk.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/2_archchk.sql >> ./chkreslt/$dirname/2_confchk.txt
	echo -e ""
	echo -e "" > ./chkreslt/$dirname/2_confchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Wal Setting Check #####"
	echo -e "##### Wal Setting Check #####" >> ./chkreslt/$dirname/2_confchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/2_confchk.txt
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/2_walchk.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/2_walchk.sql >> ./chkreslt/$dirname/2_confchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/2_confchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Vacuum Setting Check #####"
	echo -e "##### Vacuum Setting Check #####" >> ./chkreslt/$dirname/2_confchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/2_confchk.txt
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/2_vacuumchk.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/2_vacuumchk.sql >> ./chkreslt/$dirname/2_confchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/2_confchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Pg_hba Setting Check #####"
	echo -e "##### Pg_hba Setting Check #####" >> ./chkreslt/$dirname/2_confchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/2_confchk.txt
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/2_pghbachk.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/2_pghbachk.sql >> ./chkreslt/$dirname/2_confchk.txt
	echo -e ""
	echo -e "">> ./chkreslt/$dirname/2_confchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

else

	echo -e "##### Archive Setting Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/2_archchk.sql 
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""	

	echo -e "##### Wal Setting Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/2_walchk.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Vacuum Setting Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/2_vacuumchk.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Pg_hba Setting Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/2_pghbachk.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

fi
;;

3)
	rm ./chkreslt/$dirname/3_memchk.txt

clear

if [ "$flag" == "y" ]; then
	echo -e "##### Shared Memory Check #####"
	echo -e "##### Shared Memory Check #####" > ./chkreslt/$dirname/3_memchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/3_memchk.txt
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/3_sharedmemory.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/3_sharedmemory.sql >> ./chkreslt/$dirname/3_memchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/3_memchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Process Memory Check #####"
	echo -e "##### Process Memory Check #####" >> ./chkreslt/$dirname/3_memchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/3_memchk.txt
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/3_processmemory.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/3_processmemory.sql >> ./chkreslt/$dirname/3_memchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/3_memchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

else

	echo -e "##### Shared Memory Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/3_sharedmemory.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Process Memory Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/3_processmemory.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""
fi
;;

4)
	rm ./chkreslt/$dirname/4_processchk.txt

clear

if [ "$flag" == "y" ]; then
	echo "##### Process Check #####"
	echo "##### Process Check #####" > ./chkreslt/$dirname/4_processchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/4_processchk.txt
        ps -ef |grep postgres | awk '$1 ~ /^postgres$/ {print}' | grep -v  grep | grep -v bash | grep -v ps | grep -v idle | grep -v awk
        ps -ef |grep postgres | awk '$1 ~ /^postgres$/ {print}' | grep -v  grep | grep -v bash | grep -v ps | grep -v idle | grep -v awk >> ./chkreslt/$dirname/4_processchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/4_processchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

else
	echo "##### Process Check #####"
	echo -e ""
	ps -ef |grep postgres | awk '$1 ~ /^postgres$/ {print}' | grep -v  grep | grep -v bash | grep -v ps | grep -v idle | grep -v awk
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

fi
;;

5)
	rm ./chkreslt/$dirname/5_spaceusage.txt

clear

if [ "$flag" == "y" ]; then
	echo -e "##### Disk Usage Check #####"
	echo -e "##### Disk Usage Check #####" >> ./chkreslt/$dirname/5_spaceusage.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/5_spaceusage.txt
        df -h $PGDATA
        df -h $PGDATA >> ./chkreslt/$dirname/5_spaceusage.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/5_spaceusage.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Current PGDATA Usage Check #####"
	echo -e "##### Current PGDATA Usage Check #####" >> ./chkreslt/$dirname/5_spaceusage.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/5_spaceusage.txt
        du -sh $PGDATA
        du -sh $PGDATA >> ./chkreslt/$dirname/5_spaceusage.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/5_spaceusage.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Current TABLESPACE Usage Check #####"
	echo -e "##### Current TABLESPACE Usage Check #####" >> ./chkreslt/$dirname/5_spaceusage.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/5_spaceusage.txt
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$owname'" -f ./sql/5_tbssize.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$owname'" -f ./sql/5_tbssize.sql >> ./chkreslt/$dirname/5_spaceusage.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/5_spaceusage.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Database Size Check #####"
	echo -e "##### Database Size Check #####" >> ./chkreslt/$dirname/5_spaceusage.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/5_spaceusage.txt
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$dbname'" -f ./sql/5_dbsize.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$dbname'" -f ./sql/5_dbsize.sql >> ./chkreslt/$dirname/5_spaceusage.txt
##"select datname as database_name, pg_size_pretty(pg_database_size('$dbname')) as database_size from pg_database where datname='$dbname';"
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/5_spaceusage.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Table & Index Size Check #####"
	echo -e "##### Table & Index Size Check #####" >> ./chkreslt/$dirname/5_spaceusage.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/5_spaceusage.txt
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/5_tbixsize.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/5_tbixsize.sql >> ./chkreslt/$dirname/5_spaceusage.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/5_spaceusage.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""
 
else

	echo -e "##### Disk Usage Check #####"
	echo -e ""
	df -h $PGDATA
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Current PGDATA Usage Check #####"
	echo -e ""
	du -sh $PGDATA
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Current TABLESPACE Usage Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$owname'" -f ./sql/5_tbssize.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Database Size Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$dbname'" -f ./sql/5_dbsize.sql
##"select datname as database_name, pg_size_pretty(pg_database_size('$dbname')) as database_size from pg_database where datname='$dbname';"
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Table & Index Size Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/5_tbixsize.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

fi
;;

6)
	rm ./chkreslt/$dirname/6_resourcechk.txt

clear

if [ "$flag" == "y" ]; then
	echo -e "##### Current Cpu Usage #####"
	echo -e "##### Current Cpu Usage #####" > ./chkreslt/$dirname/6_resourcechk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/6_resourcechk.txt
	vmstat 1 5
	vmstat 1 5 >> ./chkreslt/$dirname/6_resourcechk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/6_resourcechk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo "##### DATA Files Directory Check #####"
	echo "##### DATA Files Directory Check #####" >> ./chkreslt/$dirname/6_resourcechk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/6_resourcechk.txt
	ls -al $PGDATA
	ls -al $PGDATA >> ./chkreslt/$dirname/6_resourcechk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/6_resourcechk.txt
	read -p "##### Press Enter #####" ynread
	echo ""

	echo -e "##### Wal Files Directory Check #####"
	echo -e "##### Wal Files Directory Check #####" >> ./chkreslt/$dirname/6_resourcechk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/6_resourcechk.txt
	ls -al $PGDATA/pg_wal
	ls -al $PGDATA/pg_wal >> ./chkreslt/$dirname/6_resourcechk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/6_resourcechk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""


	echo -e "##### Temp Files Directory Check #####"
	echo -e "##### Temp Files Directory Check #####" >> ./chkreslt/$dirname/6_resourcechk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/6_resourcechk.txt
	ls -al $PGDATA/pg_stat_tmp
	ls -al $PGDATA/pg_stat_tmp >> ./chkreslt/$dirname/6_resourcechk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/6_resourcechk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Clog Files Directory Check #####"
	echo -e "##### Clog Files Directory Check #####" >> ./chkreslt/$dirname/6_resourcechk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/6_resourcechk.txt
	ls -al $PGDATA/pg_xact
	ls -al $PGDATA/pg_xact >> ./chkreslt/$dirname/6_resourcechk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/6_resourcechk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Stat Files Directory Check #####"
	echo -e "##### Stat Files Directory Check #####" >> ./chkreslt/$dirname/6_resourcechk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/6_resourcechk.txt
	ls -al $PGDATA/pg_stat
	ls -al $PGDATA/pg_stat >> ./chkreslt/$dirname/6_resourcechk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/6_resourcechk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Log Files Directory Check#####"
	echo -e "##### Log Files Directory Check#####" >> ./chkreslt/$dirname/6_resourcechk.txt
	echo -e "" 
	echo -e "" >> ./chkreslt/$dirname/6_resourcechk.txt
	ls -al $PGDATA/log
	ls -al $PGDATA/log >> ./chkreslt/$dirname/6_resourcechk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/6_resourcechk.txt
	read -p "##### Press Enter #####" ynread
	echo ""

else

	echo -e"##### Current Cpu Usage #####"
	echo -e ""
	vmstat 1 5
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### DATA Files Directory Check #####"
	echo -e ""
	ls -al $PGDATA
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Wal Files Directory Check #####"
	echo -e ""
	ls -al $PGDATA/pg_wal
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Temp Files Directory Check #####"
	echo -e ""
	ls -al $PGDATA/pg_stat_tmp
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""
	
	echo -e "##### Clog Files Directory Check #####"
	echo -e ""
	ls -al $PGDATA/pg_xact
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Stat Files Directory Check #####"
	echo -e ""
	ls -al $PGDATA/pg_stat
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Log Files Directory Check#####"
	echo -e ""
	ls -al $PGDATA/log
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

fi
;;

7)
	rm ./chkreslt/$dirname/7_diskiochk.txt

clear

if [ "$flag" == "y" ]; then
	echo -e "##### Disk I/O Check #####"
	echo -e "##### Disk I/O Check #####" > ./chkreslt/$dirname/7_diskiochk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/7_diskiochk.txt
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$dbname'" -f ./sql/7_diskio.sql
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$dbname'" -f ./sql/7_diskio.sql >> ./chkreslt/$dirname/7_diskiochk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/7_diskiochk.txt
	read -p "##### Press Enter #####" ynread
	echo -e "" 

else

	echo -e "##### Disk I/O Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$dbname'" -f ./sql/7_diskio.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

fi
;;

8)
	rm ./chkreslt/$dirname/8_cursessionchk.txt

clear

if [ "$flag" == "y" ]; then
	echo -e "##### Current Session Check ##### "
	echo -e "##### Current Session Check ##### " > ./chkreslt/$dirname/8_cursessionchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/8_cursessionchk.txt
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/8_sessioncheck.sql
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/8_sessioncheck.sql >> ./chkreslt/$dirname/8_cursessionchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/8_cursessionchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

        echo -e "##### Current Transaction Check ##### "
        echo -e "##### Current Transaction Check ##### " >> ./chkreslt/$dirname/8_cursessionchk.txt
        echo -e ""
        echo -e "" >> ./chkreslt/$dirname/8_cursessionchk.txt
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/8_transactionchk.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/8_transactionchk.sql >> ./chkreslt/$dirname/8_cursessionchk.txt
        echo -e ""
        echo -e "" >> ./chkreslt/$dirname/8_cursessionchk.txt
        read -p "##### Press Enter #####" ynread
        echo -e ""

else

	echo -e "##### Current Session Check ##### "
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/8_sessioncheck.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""


        echo -e "##### Current Transaction Check ##### "
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/8_transactionchk.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

fi
;;
9)
	rm ./chkreslt/$dirname/8_cursessionchk.txt
	
clear

if [ "$flag" == "y" ]; then
	echo -e "##### Top 10 Sql Check #####"
	echo -e "##### Top 10 Sql Check #####" > ./chkreslt/$dirname/9_topsqlchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/9_topsqlchk.txt
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$dbname'" -f ./sql/9_topsqlchk.sql
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$dbname'" -f ./sql/9_topsqlchk.sql >> ./chkreslt/$dirname/9_topsqlchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/9_topsqlchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Top 10 sql plan Check #####"
        echo -e "##### Top 10 sql plan Check #####" >> ./chkreslt/$dirname/9_topsqlchk.txt
        echo -e ""
        echo -e "" >> ./chkreslt/$dirname/9_topsqlchk.txt
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$dbname'" -f ./sql/9_sqlplan.sql
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$dbname'" -f ./sql/9_sqlplan.sql >> ./chkreslt/$dirname/9_topsqlchk.txt

	#find /var/lib/pgsql/check/sql -name "99_extra.sql" -exec perl -pi -e 's/\\n/ /g' {} \;
        echo -e ""
        echo -e "" >> ./chkreslt/$dirname/9_topsqlchk.txt
        read -p "##### Press Enter #####" ynread
        echo -e ""

else
	echo -e "##### Top 10 Sql Check #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$dbname'" -f ./sql/9_topsqlchk.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

        echo -e "##### Top 10 sql plan Check #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -d $dbname -v v1="'$dbname'" -f ./sql/9_sqlplan.sql

        #find /var/lib/pgsql/check/sql -name "99_extra.sql" -exec perl -pi -e 's/\\n/ /g' {} \;
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""
fi
;;
10)
	rm ./chkreslt/$dirname/10_vacuumchk.txt
clear

if [ "$flag" == "y" ]; then
	echo -e "##### Tuple Check #####"
	echo -e "##### Tuple Check #####" > ./chkreslt/$dirname/10_vacuumchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/10_vacuumchk.txt
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/10_tuplestate.sql
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/10_tuplestate.sql >> ./chkreslt/$dirname/10_vacuumchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/10_vacuumchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Table Size Check #####"
	echo -e "##### Table Size Check #####" >> ./chkreslt/$dirname/10_vacuumchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/10_vacuumchk.txt
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/10_tableusage.sql
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/10_tableusage.sql >> ./chkreslt/$dirname/10_vacuumchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/10_vacuumchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Vacuum & Analyze Check #####"
	echo -e "##### Vacuum & Analyze Check #####" >> ./chkreslt/$dirname/10_vacuumchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/10_vacuumchk.txt
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/10_vacuumcheck.sql
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/10_vacuumcheck.sql >> ./chkreslt/$dirname/10_vacuumchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/10_vacuumchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Real-Time Vacuum Check #####"
	echo -e "##### Real-Time Vacuum Check #####" >> ./chkreslt/$dirname/10_vacuumchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/10_vacuumchk.txt
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/10_vacuumstate.sql
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/10_vacuumstate.sql >> ./chkreslt/$dirname/10_vacuumchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/10_vacuumchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

else

	echo -e "##### Tuple Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/10_tuplestate.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Table Size Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/10_tableusage.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Vacuum & Analyze Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/10_vacuumcheck.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Real-Time Vacuum Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/10_vacuumstate.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

fi
;;

11)
	rm ./chkreslt/$dirname/11_logchk.txt

clear

if [ "$flag" == "y" ]; then
	echo -e "##### PGLOG Check #####"
	echo -e "##### PGLOG Check #####" > ./chkreslt/$dirname/11_logchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/11_logchk.txt
	ls -alrt $PGDATA/log
	ls -alrt $PGDATA/log >> ./chkreslt/$dirname/11_logchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/11_logchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### PGLOG Error Check #####"
	echo -e "##### PGLOG Error Check #####" >> ./chkreslt/$dirname/11_logchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/11_logchk.txt
	grep -i 오류 $PGDATA/log/postgresql*
	grep -i 오류 $PGDATA/log/postgresql* >> ./chkreslt/$dirname/11_logchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/11_logchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e ""
	echo -e ""

else

	echo -e "##### PGLOG Check #####"
	echo -e ""
	ls -alrt $PGDATA/log
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo ""

	echo -e "##### PGLOG Error Check #####"
	echo -e ""
	grep -i 오류 $PGDATA/log/postgresql*
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

fi
;;

12)
	rm ./chkreslt/$dirname/12_lockchk.txt

clear

if [ "$flag" == "y" ]; then
	echo -e "##### Lock Check #####"
	echo -e "##### Lock Check #####" > ./chkreslt/$dirname/12_lockchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/12_lockchk.txt
#psql -f /var/lib/pgsql/check/sql/0_version.sql ##version check
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/12_check_lock.sql
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/12_check_lock.sql >> ./chkreslt/$dirname/12_lockchk.txt
	echo -e ""
	echo -e "" >> ./chkreslt/$dirname/12_lockchk.txt
	read -p "##### Press Enter #####" ynread
	echo -e "" 

else

	echo -e "##### Lock Check #####"
#psql -f /var/lib/pgsql/check/sql/0_version.sql ##version check
	echo -e
	PGPASSWORD=$ownpwd psql -U $owname -d $dbname -f ./sql/12_check_lock.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""
fi
;;

\c)

while true
do
echo "Input Database Name : "
read dbname
echo -e ""

result1=$(PGPASSWORD=$defpwd psql -U $defown -d $defdb -v v1="'$dbname'" -f ./sql/dbcheck.sql)

if [[ "$result1" == *0* ]]; then
 	dbname="NULL"
 	echo "##### Not Found Database!! Please Retry #####"
 	echo -e ""
 	echo -e ""
else
 	echo "##### Database Checked #####"
 	echo -e ""
 	echo -e ""
 	break;
fi

done

while true
do
echo "Input Owner Name : "
read owname
echo -e ""

result2=$(PGPASSWORD=$defpwd psql -U $defown -d $defdb -v v1="'$owname'" -f ./sql/usercheck.sql)

if [[ "$result2" == *0* ]]; then
 	owname2="NULL"
 	echo "##### Not Found Owner!! Please Retry #####"
 	echo -e ""
else
 	echo "##### Owner Checked #####"
 	echo -e ""
 	echo -e ""
 	break;
fi

done

while true
do
echo "Input Owner Password : "
read -s ownpwd
echo -e ""

result3="NULL"
result3=$(PGPASSWORD=$ownpwd psql -U $owname -d $dbname -c "select version()")

if [[ "$result3" == *PostgreSQL* ]]; then
 	echo "##### Password Checked #####"
 	echo -e ""
 	break;
else
 	echo "##### Password Incorrect!! Please Retry #####"
 	echo -e ""
 	echo -e ""
fi

done

if [ "$flag" == "y" ]; then

if [ "$dirname" = "$dbname" ]; then
	echo -e "##### Alrerady Created Directory #####"
else
	mkdir ./chkreslt/$dbname
fi

else
	echo -e ""
fi
;;

\f)
if [ "$flag" == "y" ]; then
	echo -e "##### File Write Mode Change On -> Off #####"
	flag="n"
else if [ "$flag" == "n" ]; then
	echo -e "##### File Write Mode Change Off -> On #####"
	flag="y"
fi
fi
;;

\q)
echo "##### Check Finish!! #####"
break;;

"")
continue
;;

*)
echo "##### Wrong Number!!! #####"

esac

done
