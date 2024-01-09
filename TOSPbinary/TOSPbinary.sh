#!/bin/bash
####################################
## opensql postgresql 기술지원 shell
## File name : pgcheck.sh
## Modified History
## son young been (ver1.0)
####################################

echo -e ""
echo "##### Start Tmax OpenSQL for PostgreSQL Binary #####"
echo -e ""

defdb="postgres"
defown="postgres"
defpwd="postgres"
defport="5432"
defpghome="/var/lib/pgsql/"
defpgdata="/var/lib/pgsql/15/data"
defwaldir="/var/lib/pgsql/15/pg_wal"
deflogdir="/var/lib/pgsql/15/log/pg_log"
defarchive="/var/lib/pgsql/15/archive"

dbname=$defdb
owname=$defown
ownpwd=$defpwd
portnum=$defport
datapath=$defpgdata
walpath=$defwaldir
logpath=$deflogdir
archpath=$defarchive


 echo "Input User Name(default : postgres) : "
   read owname
   if [[ -z "$owname" ]]; then
               owname=$defown
   fi

 echo "Input User Password(default : postgres) : "
  read ownpwd
  if [[ -z "$ownpwd" ]]; then
               ownpwd=$defpwd
  fi

 echo "Input Database Name(default : postgres) : "
   read imsidbname
   if [[ -z "$imsidbname" ]]; then
                imsidbname=$defdb
		dbname=$imsidbname
   else
	dbname=$imsidbname
   fi

 echo "Input Port Number(default : 5432) : "
   read portnum
   if [[ -z "$portnum" ]]; then
                portnum=$defport
   fi




while true
do

clear

echo "
######################## SELECT CONTENTS ########################
# 00. Version			# 11. PG Process		#
# 01. Database & Owner		# 12. Session			#
# 02. Tablespace		# 13. Log			#
# 03. Archive Check		# 14. Vacuum & Analyze		#
# 04. Postgresql.conf		# 15. Live & Dead Tuples	#
# 05. Pg_hba.conf		# 16. Lock			#
# 06. Memory Configure	 	# 17. Extension	list		#
# 07. Shared Memory Status	# 18. Top 10 Query ID		#
# 08. Hit ratio			# 19. Query Information		#
# 09. Disk Size			# 20. Txid Wraparound check	#
# 10. Data Size			#				#
#################################################################
# \c. Change Default Connection Info				#
# \p. Change Default Path 					#
# \f. Result File download					#
# \q. Exit Program						#
#################################################################
"

echo "input number : " 
read num
echo -e ""

dirname=${dbname}

case $num in
00)
clear

	echo -e "##### Version Check #####"
	echo -e ""
#psql -f /var/lib/pgsql/check/sql/0_version.sql
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/00/00_version.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""
;;

01)
clear

	echo -e "##### Database & Owner List Check #####"
	echo -e ""
#psql -f /var/lib/pgsql/check/sql/0_dblist.sql
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/01/01_dblist.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""
;;

02)
clear

        pg_base="$PGDATA/base"
        pg_global="$PGDATA/global"

        echo -e "##### Tablespace #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -v v1="'$pg_base'" -v v2="'$pg_global'" -f ./sql/02/02_tablespace.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

        echo -e "##### Disk Free Space #####"
        echo -e ""
	query_result=$(PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -tc "SELECT case when spcname='pg_default' then '$pg_base' when spcname='pg_global' then '$pg_global' else pg_tablespace_location(oid) end as location, pg_tablespace_size(oid) AS size, spcname FROM pg_tablespace;")
        
	IFS=$'\n'
	for row in $query_result; do
    		spcdir=$(echo "$row" | awk '{print $1}')
		spcname=$(echo "$row" | awk '{print $5}')
    		disk_space=$(df $spcdir | tail -n +2 | awk '{print $2}')
		#disk_space_byte=$(echo "$disk_space * 1024" | bc)
		disk_space_byte=$(echo $(($disk_space * 1024)))
    		free_size=$(df $spcdir | tail -n +2 | awk '{print $4}')
		#free_byte=$(echo "$free_size * 1024" | bc)
		free_byte=$(echo $(($free_size * 1024)))
		#size=$(echo "$row" | awk '{print $3}')
    		#percentage=$(echo "scale=2; ($free_byte / $disk_space_byte) * 100" | bc)
    		percentage=$(echo "$free_byte; $disk_space_byte" | awk '{printf "%.2f", ($1 / $2) * 100}')
		echo "$spcname : $free_byte / $disk_space_byte(free/total) $percentage% free"
	done
	echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

;;

03)

clear

        echo -e "##### Archive Check #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -c "show archive_mode;" -c "SELECT setting as archive_state_directory FROM pg_settings where name='archive_command';"
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

;;

04)

clear

        echo -e "##### postgresql.conf Check #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/04/04_postgresqlconf.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

;;

05)
clear
	echo -e "##### Pg_hba Setting Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/05/05_pghbachk.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

;;

06)

clear

        echo -e "##### Shared Memory Configure #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/06/06_sharedmemory.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

        echo -e "##### Process Memory Check #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/06/06_processmemory.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

;;

07)

clear

	echo -e "##### Database Memory Usage #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/07/07_dbmemusage.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

        echo -e "##### Table Memory Usage #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/07/07_tblmemusage.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

;;

08)

clear

        echo -e "##### Buffer Cache Hit ratio #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/08/08_bufferhit.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

        echo -e "##### Table Hit ratio #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/08/08_tablehit.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

        echo -e "##### Index Hit ratio #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/08/08_indexhit.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

;;

09)

clear

	echo -e "##### Data Cluster Size #####"
	echo -e ""
	echo "Data Cluster Disk Usage"
	du -sh $datapath
	echo -e ""
	echo "Disk Freespace"
	disk_space1=$(df $datapath | tail -n +2 | awk '{print $2}')
	used_space1=$(df $walpath | tail -n +2 | awk '{print $3}')
	#free_space1=$(echo "$disk_space1 - $used_space1" | bc)
	free_space1=$(echo $(($disk_space1 - $used_space1)))
	#free_percentage1=$(echo "scale=2; ($free_space1 / $disk_space1) * 100" | bc)
	free_percentage1=$(echo "$free_space1; $disk_space1" | awk '{printf "%.2f", ($1 / $2) * 100}')
	echo "free percentage : $free_percentage1%"	
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

        echo -e "##### WAL Directory Size #####"
        echo -e ""
	echo "WAL Disk Usage"
        du -sh $walpath
        echo -e ""
	echo "Disk Freespace"
        disk_space2=$(df $walpath | tail -n +2 | awk '{print $2}')
        used_space2=$(df $walpath | tail -n +2 | awk '{print $3}')
        #free_space2=$(echo "$disk_space2 - $used_space2" | bc)
        free_space2=$(echo $(($disk_space2 - $used_space2)))
	#free_percentage2=$(echo "scale=2; ($free_space2 / $disk_space2) * 100" | bc)
	free_percentage2=$(echo "$free_space2; $disk_space2" | awk '{printf "%.2f", ($1 / $2) * 100}')
	echo "free percentage : $free_percentage2%"
	echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

        echo -e "##### Log Directory Size #####"
        echo -e ""
	echo "Log Disk Usage"
        du -sh $logpath
        echo -e ""
	echo "Disk Freespace"
	disk_space3=$(df $walpath | tail -n +2 | awk '{print $2}')
        used_space3=$(df $walpath | tail -n +2 | awk '{print $3}')
        #free_space3=$(echo "$disk_space3 - $used_space3" | bc)
	free_space3=$(echo $(($disk_space3 - $used_space3)))
        #free_percentage3=$(echo "scale=2; ($free_space3 / $disk_space3) * 100" | bc)
	free_percentage3=$(echo "$free_space3; $disk_space3" | awk '{printf "%.2f", ($1 / $2) * 100}')
	echo "free percentage : $free_percentage3%"
	echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

        echo -e "##### Archive Directory Size #####"
        echo -e ""
	echo "Archive Disk Usage"
        du -sh $archpath
        echo -e ""
	echo "Disk Freespace"
        disk_space4=$(df $walpath | tail -n +2 | awk '{print $2}')
        used_space4=$(df $walpath | tail -n +2 | awk '{print $3}')
        #free_space4=$(echo "$disk_space4 - $used_space4" | bc)
	free_space4=$(echo $(($disk_space4 - $used_space4)))
        #free_percentage4=$(echo "scale=2; ($free_space4 / $disk_space4) * 100" | bc)
        free_percentage4=$(echo "$free_space4; $disk_space4" | awk '{printf "%.2f", ($1 / $2) * 100}')
	echo "free percentage : $free_percentage4%"
	echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""
;;

10)

clear

        echo -e "##### Database Size #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/10/10_dbsize.sql
##"select datname as database_name, pg_size_pretty(pg_database_size('$dbname')) as database_size from pg_database where datname='$dbname';"
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

        echo -e "##### Table & Index Size #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -f ./sql/10/10_tbixsize.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

;;

11)

clear

        echo "##### Process Check #####"
        echo -e ""
        ps -ef |grep postgres | grep -v  grep | grep -v bash | grep -v ps | grep -v idle | grep -v awk
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

;;

12)

clear

	echo -e "##### Session Status ##### "
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/12/12_sessioncheck.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""


        echo -e "##### Transaction Status ##### "
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/12/12_transactionchk.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

;;

13)
	
clear

        echo -e "##### PGLOG Check #####"
        echo -e ""
        ls -alrt $logpath
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo ""
	
	if [ -d ./log_error_list ]; then
		echo "directory exist"
		datetime=`date +%Y%m%d%H%M%S`
	else
		mkdir ./log_error_list
	fi

        echo -e "##### PGLOG Error Check #####"
        echo -e ""
	echo -e "##### Writing ERROR LOG ON FILE #####"
	echo -e ""
        grep -i -E "오류|error" $logpath/postgresql* >> ./log_error_list/error_$datetime.txt
        echo -e ""
	if [ -e ./log_error_list/error_$datetime.txt ]; then
		echo "##### Finish write file #####"
	else
		echo "##### FILE writing failed... #####"
	fi
	echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

;;

14)
clear

	echo -e "##### Vacuum & Analyze Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -f ./sql/14/14_vacuumcheck.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

	echo -e "##### Real-Time Vacuum Check #####"
	echo -e ""
	PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -f ./sql/14/14_vacuumstate.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""

;;

15)

clear

	echo -e "##### Tuple Check #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -f ./sql/15/15_tuplestate.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

;;

16)

clear

	echo -e "##### Lock Check #####"
#psql -f /var/lib/pgsql/check/sql/0_version.sql ##version check
	echo -e
	PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -f ./sql/16/16_check_lock.sql
	echo -e ""
	read -p "##### Press Enter #####" ynread
	echo -e ""
;;

17)

clear

        echo -e "##### extension list #####"
        echo -e
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -f ./sql/17/17_extension_list.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""
;;

18)

clear

        echo -e "##### Top 10 Query ID #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/18/18_topqueryID.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

;;

19)

clear

        echo -e "##### Query Information #####"
        echo -e ""
	echo "input query ID : "
	read queryid
	echo -e ""
	if [[ -z "$queryid" ]]; then
		echo "Please input queryid!!"
		read -p "##### Press Enter #####" ynread
        else
	PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -v v2="'$queryid'" -f ./sql/19/19_queryinfo.sql
	echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""
	fi

;;

20)

clear

        echo -e "##### Transaction Wraparound DB Check #####"
        echo -e ""
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/20/20_txwraparound_db.sql
        echo -e ""
        read -p "##### Press Enter #####" ynread
        echo -e ""

#        echo -e "##### Transaction Wraparound TABLE Check #####"
#        echo -e ""
#        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/20/20_txwraparound_table.sql
#        echo -e ""
#        read -p "##### Press Enter #####" ynread
#        echo -e ""




;;


\c)

echo "Input Owner Name(default : postgres) : "
read owname
if [[ -z "$owname" ]]; then
        owname=$defown
fi

echo "Input Owner Password(default : postgres) : "
read -s ownpwd
if [[ -z "$ownpwd" ]]; then
        ownpwd=$defpwd
fi

echo "Input Database Name(default : postgres) : "
read imsidbname
if [[ -z "$dbname" ]]; then
        imsidbname=$defdb
	dbname=$imsidbname
else
	dbname=$imsidbname
fi


echo "Input Port Number(default : 5432) : "
read portnum
if [[ -z "$portnum" ]]; then
        portnum=$defport
fi


;;

\p)
echo "Input Data Cluster Path(default : $defpgdata)  : "
read datapath
if [[ -z "$datapath" ]]; then
        datapath=$defpgdata
fi
echo $datapath

echo "Input Wal Path(default : $defwaldir) : "
read walpath
if [[ -z "$walpath" ]]; then
	walpath=$defwaldir
fi
echo $walpath

echo "Input PgLog Path(default : $deflogdir) : "
read logpath
if [[ -z "$logpath" ]]; then
	logpath=$deflogdir
fi
echo $logpath

echo "Input Archive Path(default : $defarchive) : "
read archpath
if [[ -z "$archpath" ]]; then
	archpath=$defarchive
fi
echo $archpath

;;


\f)
	if [ -d ./chkreslt ]; then
		datetime=`date +%Y%m%d%H%M%S`
		echo "dir exists, move old file to $datetime"
		mkdir ./chkreslt/$datetime
		mv ./chkreslt/*.txt ./chkreslt/$datetime
	else
		mkdir ./chkreslt
	fi

	echo -e "##### Version Check #####" >> ./chkreslt/0_version.txt
	echo -e "" >> ./chkreslt/0_version.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/00/00_version.sql >> ./chkreslt/00_version.txt
	echo -e "" >> ./chkreslt/0_version.txt

	echo -e "##### Database & Owner List Check #####" >> ./chkreslt/1_dbownerchk.txt
	echo -e "" >> ./chkreslt/1_dbownerchk.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/01/01_dblist.sql >> ./chkreslt/01_dbownerchk.txt
	echo -e "" >> ./chkreslt/1_dbownerchk.txt

	pg_base="$PGDATA/base"
        pg_global="$PGDATA/global"
	echo -e "##### Tablespace #####" >> ./chkreslt/2_tablespace.txt
	echo -e "" >> ./chkreslt/2_tablespace.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -v v1="'$pg_base'" -v v2="'$pg_global'" -f ./sql/02/02_tablespace.sql >> ./chkreslt/02_tablespace.txt
	echo -e "" >> ./chkreslt/2_tablespace.txt
	
	echo -e "##### Disk Free Space #####" >> ./chkreslt/2_tablespace.txt
        echo -e "" >> ./chkreslt/2_tablespace.txt
	query_result=$(PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -tc "SELECT case when spcname='pg_default' then '$pg_base' when spcname='pg_global' then '$pg_global' else pg_tablespace_location(oid) end as location, pg_tablespace_size(oid) AS size, spcname FROM pg_tablespace;")
        
	IFS=$'\n'
	for row in $query_result; do
    		spcdir=$(echo "$row" | awk '{print $1}')
		spcname=$(echo "$row" | awk '{print $5}')
    		disk_space=$(df $spcdir | tail -n +2 | awk '{print $2}')
    		#disk_space_byte=$(echo "$disk_space * 1024" | bc)
    		disk_space_byte=$(echo $(($disk_space * 1024)))
		free_size=$(df $spcdir | tail -n +2 | awk '{print $4}')
		#free_byte=$(echo "$free_size * 1024" | bc)
		free_byte=$(echo $(($free_size * 1024)))
		#size=$(echo "$row" | awk '{print $3}')
    		#percentage=$(echo "scale=2; ($free_byte / $disk_space_byte) * 100" | bc)
		percentage=$(echo "$free_byte; $disk_space_byte" | awk '{printf "%.2f", ($1 / $2) * 100}')
    		echo "$spcname : $free_byte / $disk_space_byte(free/total) $percentage% free" >> ./chkreslt/02_tablespace.txt
	done
	echo -e "" >> ./chkreslt/02_tablespace.txt

	echo -e "##### Archive Check #####" >> ./chkreslt/03_archive.txt
	echo -e "" >> ./chkreslt/03_archive.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -c "show archive_mode;" -c "SELECT setting as archive_state_directory FROM pg_settings where name='archive_command';" >> ./chkreslt/03_archive.txt
	echo -e "" >> ./chkreslt/03_archive.txt	

	echo -e "##### postgresql.conf Check #####" >> ./chkreslt/04_postgresqlconf.txt
	echo -e "" >> ./chkreslt/04_postgresqlconf.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/4/4_postgresqlconf.sql >> ./chkreslt/04_postgresqlconf.txt
	echo -e "" >> ./chkreslt/04_postgresqlconf.txt

	echo -e "##### Pg_hba Setting Check #####" >> ./chkreslt/05_pghbaconf.txt
	echo -e "" >> ./chkreslt/05_pghbaconf.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/05/05_pghbachk.sql >> ./chkreslt/05_pghbaconf.txt
	echo -e "">> ./chkreslt/05_pghbaconf.txt

	echo -e "##### Shared Memory Configure #####" >> ./chkreslt/06_memconfig.txt
	echo -e "" >> ./chkreslt/06_memconfig.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/06/06_sharedmemory.sql >> ./chkreslt/06_memconfig.txt
	echo -e "" >> ./chkreslt/06_memconfig.txt

        echo -e "##### Process Memory Check #####" >> ./chkreslt/06_memconfig.txt
        echo -e "" >> ./chkreslt/06_memconfig.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/06/06_processmemory.sql >> ./chkreslt/06_memconfig.txt
        echo -e "" >> ./chkreslt/06_memconfig.txt

	echo -e "##### Database Memory Usage #####" >> ./chkreslt/07_shmemstatus.txt
	echo -e "" >> ./chkreslt/07_shmemstatus.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/07/07_dbmemusage.sql >> ./chkreslt/07_shmemstatus.txt
	echo -e "" >> ./chkreslt/07_shmemstatus.txt

        echo -e "##### Table Memory Usage #####" >> ./chkreslt/07_shmemstatus.txt
        echo -e "" >> ./chkreslt/07_shmemstatus.txt
        echo -e "" >> ./chkreslt/07_shmemstatus.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/07/07_tblmemusage.sql >> ./chkreslt/07_shmemstatus.txt
        echo -e "" >> ./chkreslt/07_shmemstatus.txt

        echo -e "##### Buffer Cache Hit ratio #####" >> ./chkreslt/08_hitratio.txt
        echo -e "" >> ./chkreslt/08_hitratio.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/08/08_bufferhit.sql >> ./chkreslt/08_hitratio.txt
        echo -e "" >> ./chkreslt/08_hitratio.txt

        echo -e "##### Table Hit ratio #####" >> ./chkreslt/08_hitratio.txt
        echo -e "" >> ./chkreslt/08_hitratio.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/08/08_tablehit.sql >> ./chkreslt/08_hitratio.txt
        echo -e "" >> ./chkreslt/08_hitratio.txt

        echo -e "##### Index Hit ratio #####" >> ./chkreslt/8_hitratio.txt
        echo -e "" >> ./chkreslt/08_hitratio.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/08/08_indexhit.sql >> ./chkreslt/08_hitratio.txt
        echo -e "" >> ./chkreslt/08_hitratio.txt

	echo -e "##### Data Cluster Size #####" >> ./chkreslt/09_disksize.txt
	echo -e "" >> ./chkreslt/09_disksize.txt
	echo "Data Cluster Disk Usage" >> ./chkreslt/09_disksize.txt
        du -sh $datapath >> ./chkreslt/09_disksize.txt
	echo -e "" >> ./chkreslt/09_disksize.txt
	echo "Disk Freespace" >> ./chkreslt/09_disksize.txt
	disk_space1=$(df $datapath | tail -n +2 | awk '{print $2}')
	used_space1=$(df $walpath | tail -n +2 | awk '{print $3}')
	#free_space1=$(echo "$disk_space1 - $used_space1" | bc)
	free_space1=$(echo $(($disk_space1 - $used_space1)))
	#free_percentage1=$(echo "scale=2; ($free_space1 / $disk_space1) * 100" | bc)
	free_percentage1=$(echo "$free_space1; $disk_space1" | awk '{printf "%.2f", ($1 / $2) * 100}')
	echo "free percentage : $free_percentage1%" >> ./chkreslt/09_disksize.txt
	echo -e "" >> ./chkreslt/09_disksize.txt

        echo -e "##### WAL Directory Size #####" >> ./chkreslt/09_disksize.txt
        echo -e "" >> ./chkreslt/09_disksize.txt
	echo "WAL Disk Usage" >> ./chkreslt/09_disksize.txt
        du -sh $walpath >> ./chkreslt/09_disksize.txt
        echo -e "" >> ./chkreslt/09_disksize.txt
	echo "Disk Freespace" >> ./chkreslt/09_disksize.txt
        disk_space2=$(df $walpath | tail -n +2 | awk '{print $2}')
        used_space2=$(df $walpath | tail -n +2 | awk '{print $3}')
        #free_space2=$(echo "$disk_space2 - $used_space2" | bc)
        free_space2=$(echo $(($disk_space2 - $used_space2)))
	#free_percentage2=$(echo "scale=2; ($free_space2 / $disk_space2) * 100" | bc)
	free_percentage2=$(echo "$free_space2; $disk_space2" | awk '{printf "%.2f", ($1 / $2) * 100}')
	echo "free percentage : $free_percentage2%" >> ./chkreslt/09_disksize.txt
	echo -e "" >> ./chkreslt/09_disksize.txt

        echo -e "##### Log Directory Size #####" >> ./chkreslt/09_disksize.txt
        echo -e "" >> ./chkreslt/09_disksize.txt
	echo "Log Disk Usage" >> ./chkreslt/09_disksize.txt
        du -sh $logpath >> ./chkreslt/09_disksize.txt
        echo -e "" >> ./chkreslt/09_disksize.txt
	echo "Disk Freespace" >> ./chkreslt/09_disksize.txt
	disk_space3=$(df $walpath | tail -n +2 | awk '{print $2}')
        used_space3=$(df $walpath | tail -n +2 | awk '{print $3}')
        #free_space3=$(echo "$disk_space3 - $used_space3" | bc)
	free_space3=$(echo $(($disk_space3 - $used_space3)))
        #free_percentage3=$(echo "scale=2; ($free_space3 / $disk_space3) * 100" | bc)
	free_percentage3=$(echo "$free_space3; $disk_space3" | awk '{printf "%.2f", ($1 / $2) * 100}')
	echo "free percentage : $free_percentage3%" >> ./chkreslt/09_disksize.txt
	echo -e "" >> ./chkreslt/09_disksize.txt

        echo -e "##### Archive Directory Size #####" >> ./chkreslt/09_disksize.txt
        echo -e "" >> ./chkreslt/09_disksize.txt
	echo "Archive Disk Usage" >> ./chkreslt/09_disksize.txt
        du -sh $archpath >> ./chkreslt/09_disksize.txt
        echo -e "" >> ./chkreslt/09_disksize.txt
	echo "Disk Freespace" >> ./chkreslt/09_disksize.txt
        disk_space4=$(df $walpath | tail -n +2 | awk '{print $2}')
        used_space4=$(df $walpath | tail -n +2 | awk '{print $3}')
        #free_space4=$(echo "$disk_space4 - $used_space4" | bc)
	free_space4=$(echo $(($disk_space4 - $used_space4)))
        #free_percentage4=$(echo "scale=2; ($free_space4 / $disk_space4) * 100" | bc)
        free_percentage4=$(echo "$free_space4; $disk_space4" | awk '{printf "%.2f", ($1 / $2) * 100}')
	echo "free percentage : $free_percentage4%" >> ./chkreslt/09_disksize.txt
	echo -e "" >> ./chkreslt/09_disksize.txt

        echo -e "##### Database Size #####" >> ./chkreslt/10_datasize.txt
        echo -e "" >> ./chkreslt/10_datasize.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/10/10_dbsize.sql >> ./chkreslt/10_datasize.txt
        echo -e "" >> ./chkreslt/10_datasize.txt

        echo -e "##### Table & Index Size #####" >> ./chkreslt/10_datasize.txt
        echo -e "" >> ./chkreslt/10_datasize.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -f ./sql/10/10_tbixsize.sql >> ./chkreslt/10_datasize.txt
        echo -e "" >> ./chkreslt/10_datasize.txt

        echo "##### Process Check #####" >> ./chkreslt/11_pgprocesschk.txt
        echo -e "" >> ./chkreslt/11_pgprocesschk.txt
        ps -ef |grep postgres | grep -v  grep | grep -v bash | grep -v ps | grep -v idle | grep -v awk >> ./chkreslt/11_pgprocesschk.txt
        echo -e "" >> ./chkreslt/11_pgprocesschk.txt

	echo -e "##### Session Status ##### " >> ./chkreslt/12_cursessionchk.txt
	echo -e "" >> ./chkreslt/12_cursessionchk.txt
	PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/12/12_sessioncheck.sql >> ./chkreslt/12_cursessionchk.txt
	echo -e "" >> ./chkreslt/12_cursessionchk.txt

        echo -e "##### Transaction Check ##### " >> ./chkreslt/12_cursessionchk.txt
        echo -e "" >> ./chkreslt/12_cursessionchk.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $dbname -q -f ./sql/12/12_transactionchk.sql >> ./chkreslt/12_cursessionchk.txt
	echo -e "" >> ./chkreslt/12_cursessionchk.txt

        echo -e "##### PGLOG Check #####" >> ./chkreslt/13_logchk.txt
        echo -e "" >> ./chkreslt/13_logchk.txt
        ls -alrt $logpath >> ./chkreslt/13_logchk.txt
        echo -e "" >> ./chkreslt/13_logchk.txt

        echo -e "##### PGLOG Error Check #####" >> ./chkreslt/13_logchk.txt
        echo -e "" >> ./chkreslt/13_logchk.txt
        grep -i -E "오류|error" $logpath/postgresql* >> ./chkreslt/13_logchk.txt
        echo -e "" >> ./chkreslt/13_logchk.txt

	echo -e "##### Vacuum & Analyze Check #####" >> ./chkreslt/14_vacuumchk.txt
	echo -e "" >> ./chkreslt/14_vacuumchk.txt
	PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -f ./sql/14/14_vacuumcheck.sql >> ./chkreslt/14_vacuumchk.txt
	echo -e "" >> ./chkreslt/14_vacuumchk.txt

	echo -e "##### Real-Time Vacuum Check #####" >> ./chkreslt/14_vacuumchk.txt
	echo -e "" >> ./chkreslt/14_vacuumchk.txt
	PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -f ./sql/14/14_vacuumstate.sql >> ./chkreslt/14_vacuumchk.txt
	echo -e "" >> ./chkreslt/14_vacuumchk.txt

        echo -e "##### Tuple Check #####" >> ./chkreslt/15_tuple.txt
        echo -e "" >> ./chkreslt/15_tuple.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -f ./sql/15/15_tuplestate.sql >> ./chkreslt/15_tuple.txt
        echo -e "" >> ./chkreslt/15_tuple.txt

	echo -e "##### Lock Check #####" >> ./chkreslt/16_lockchk.txt
	echo -e "" >> ./chkreslt/16_lockchk.txt
	PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -f ./sql/16/16_check_lock.sql >> ./chkreslt/16_lockchk.txt
	echo -e "" >> ./chkreslt/16_lockchk.txt

        echo -e "##### extension list #####" >> ./chkreslt/17_extensionlist.txt
        echo -e "" >> ./chkreslt/17_extensionlist.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -f ./sql/17/17_extension_list.sql >> ./chkreslt/17_extensionlist.txt
        echo -e "" >> ./chkreslt/17_extensionlist.txt

        echo -e "##### Top 10 Query ID #####" >> ./chkreslt/18_top10queryid.txt
        echo -e "" >> ./chkreslt/18_top10queryid.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/18/18_topqueryID.sql >> ./chkreslt/18_top10queryid.txt
        echo -e "" >> ./chkreslt/18_top10queryid.txt

	echo -e "##### Query Information #####" >> ./chkreslt/19_queryinfo.txt
        echo -e "" >> ./chkreslt/19_queryinfo.txt
	echo "input query ID : "
	echo "input query ID : " >> ./chkreslt/19_queryinfo.txt
	read queryid
	echo -e "" >> ./chkreslt/19_queryinfo.txt
	if [[ -z "$queryid" ]]; then
		echo "Please input queryid!!" >> ./chkreslt/19_queryinfo.txt
		read -p "##### Press Enter #####"  ynread
        else
	PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -v v2="'$queryid'" -f ./sql/19/19_queryinfo.sql >> ./chkreslt/19_queryinfo.txt
	echo -e "" >> ./chkreslt/19_queryinfo.txt
	fi

        echo -e "##### Transaction Wraparound DB Check #####" >> ./chkreslt/20_txwraparound.txt
        echo -e "" >> ./chkreslt/20_txwraparound.txt
        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/20/20_txwraparound_db.sql >> ./chkreslt/20_txwraparound.txt
        echo -e "" >> ./chkreslt/20_txwraparound.txt

#        echo -e "##### Transaction Wraparound TABLE Check #####" >> ./chkreslt/20_txwraparound.txt
#        echo -e "" >> ./chkreslt/20_txwraparound.txt
#        PGPASSWORD=$ownpwd psql -U $owname -p $portnum -d $imsidbname -q -v v1="'$imsidbname'" -f ./sql/20/20_txwraparound_table.sql >> ./chkreslt/20_txwraparound.txt
#        echo -e "" >> ./chkreslt/20_txwraparound.txt

;;

\q)
echo "##### Binary Finish!! #####"
break;;

"")
t
continue
;;

*)
echo "##### Wrong Number!!! #####"

esac

done
