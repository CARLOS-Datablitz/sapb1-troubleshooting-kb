#Task: Export database from the Customer "APC" located in the cloud,upload it to SFTP so you can import to Demo Clara's test system. 
# Refered iSystems#99195302
# Tenant - E06 APC

screen -dRR

#Check information through the MT - 10.3.90.2, esta informacion la sacas del sles#cat /hana/scripts/backup.conf
ssh -p 55667 isystems_tpa090@usbck.privatcloud.biz

#Go to this path in order to check the latest backups
cd Hana-Backups/backups_fbck

# Importante: la fecha real del backup es la que esta en el nombre no en el display del comando.
# Get the schemas and put them in the test environment
# Tomar en cuenta en que DC esta el MT/sles y en que SFTP(tpa o de)
sftp -P 2022 c.pecho@files.dctpa.privatcloud.biz
pass: C4!qE0e]cVFy&$m
cd /Peru/carlosph_files/APC
put 20251211_192502-DB_E06-hanamt.dctpamt090.privatcloud.biz.tgz
put 20251210_192501-DB_E06-hanamt.dctpamt090.privatcloud.biz.tgz
bye

# Hasta aquí sacar el backup desde el multitenant #####

===================================================================================================================================================================
# Ahora en el DEMO CLARA MT :
# 1 ---verificar que ejecutaste screen -dRR  -----!
# ver si hay espacion en la carpeta backup o tmp:
sles:~ # df -h
mkdir -p /backup/data/DB_E06/
cd /backup
chown -R ndbadm:sapsys data/
cd data/DB_E01/


# Get the schemas and put them in the test environment
sftp -P 2022 c.pecho@files.dctpa.privatcloud.biz
pass: C4!qE0e]cVFy&$m
cd /Peru/carlosph_files/APC
get 20251211_192502-DB_E06-hanamt.dctpamt090.privatcloud.biz.tgz
get 20251210_192501-DB_E06-hanamt.dctpamt090.privatcloud.biz.tgz
bye

#Untar all files
tar -xzf 20250910_192502-DB_E01-hanamt.dctpamt090.privatcloud.biz.tgz


#In the HANA Studio
RECOVER DATA FOR E01 USING FILE ('/backup/data/DB_E01/data/DB_E01/20250910_192502_E01_COMPLETE_DATA_BACKUP') CLEAR LOG;

#Login to the tenant using its regular SYSTEM password and run 
ALTER SYSTEM ALTER CONFIGURATION ('indexserver.ini', 'system') set ('import_export', 'enable_history_table_import_export') = 'true' with reconfigure;

===================================================================================================================================================================

#Into testv10 o DEMO CLARA to upload the schema to the SFTP

cd /tmp && ls -lha
mkdir byg BYG
chmod -R 777 byg/ BYG/
chown -R ndbadm:sapsys byg/ BYG/ && ls -lha
  
#SQL Varibles (SYSTEM)
dbSql="/hana/shared/NDB/HDB00/exe/hdbsql"
dbInstance="00"
dbHost="127.0.0.1"
dbTenant="E01"
dbUser="B1SYSTEM"
dbPass="q6xS3JFP51Mb"

#Test DB
"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" 'select * from "SYS"."SCHEMAS";'
  
# Export the schema
"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" 'export 'SBO_BUYANDGO'."*" as binary into '\'/tmp/byg\'' with ignore existing threads 10;'


# Compress schemas and save on folder
tar -C /tmp/byg -czf /tmp/BYG/SBO_BUYANDGO.tar.gz ./

cd /tmp/BYG && ls -lha


# Upload to the SFTP
sftp -P 2022 m.riera@files.privatcloud.biz
pass: A982Aj2iAh41
cd /Peru/marcos_files/BuyandGo
put SBO_BUYANDGO.tar.gz
bye

# Delete the non necessary files
cd /tmp && ls -lha && rm -rf byg/ BYG/ && ls -lha



===================================================================================================================================================================

#Into the correspinding tenant of the MT
cd /tmp
mkdir byg/
chmod -R 777 byg/ 
chown -R ndbadm:sapsys byg/ && ls -lha


#SQL Varibles (B1SYSTEM)
dbSql="/hana/shared/NDB/HDB00/exe/hdbsql"
dbInstance="00"
dbHost="127.0.0.1"
dbTenant="E01"
dbUser="B1SYSTEM"
dbPass="q6xS3JFP51Mb"

#Test DB
"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" 'select * from "SYS"."SCHEMAS";'


# Download from the SFTP
# Correr el comando en el directorio donde queremos que se encuentre el archivo
sftp -P 2022 m.riera@files.privatcloud.biz
pass: A982Aj2iAh41
cd /Peru/marcos_files/BuyandGo
get SBO_BUYANDGO.tar.gz
bye

#Untar and move to another folder
tar -xzf SBO_BUYANDGO.tar.gz -C /tmp/byg

#Import and rename the schema
"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" 'import 'SBO_BUYANDGO'."*" as binary from '\'/tmp/byg\'' WITH IGNORE EXISTING THREADS 20 RENAME SCHEMA 'SBO_BUYANDGO' TO 'TEST_100925'';