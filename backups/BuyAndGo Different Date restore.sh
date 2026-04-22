#Task: Export database from the Customer "BuyandGo" located in the cloud,upload it to SFTP so you can import to Michael's test system. 
# Refered date 4 restore: 10/09/2025
# Tenant - E01

screen -dRR

#Connect to the isc through the MT - 10.3.90.2, esta informacion la sacas del sles#cat /hana/scripts/backup.conf
ssh -p 55667 isystems_tpa090@usbck.privatcloud.biz

#Go to this path in order to check the latest backups
cd Hana-Backups/backups_fbck

# Importante: la fecha real del backup es la que esta en el nombre no en el display del comando.
# Get the schemas and put them in the test environment
sftp -P 2022 c.pecho@files.dctpa.privatcloud.biz
pass: C4!qE0e]cVFy&$m
cd /Peru/carlosph_files/APC
put 20251211_192502-DB_E06-hanamt.dctpamt090.privatcloud.biz.tgz
put 20251210_192501-DB_E06-hanamt.dctpamt090.privatcloud.biz.tgz
bye

# Hasta aquí sacar el backup desde el tenant

===================================================================================================================================================================

#Into testv10 environment to test that the upgraded schemas work fine

mkdir -p /backup/data/DB_E14/
cd /backup
chown -R ndbadm:sapsys data/
cd data/DB_E14/


# Get the schemas and put them in the test environment
testv10:/backup/data # cd DB_E14/
sftp -P 2022 c.pecho@files.dcdus.privatcloud.biz
C4!qE0e]cVFy&$m 
cd /Peru/carlos_files/
get 20250910_192502-DB_E14-hanamt.dctpamt090.privatcloud.biz.tgz
bye

#Untar all files
#DB_E14/
tar -xzf 20260329_192502-DB_E14-hanamt.dcdusmt092.privatcloud.biz.tgz
cd ..
chmod -R 777 DB_E14/


=================================================HAN STUDIO ===================================================================================
# Session : SYSTEMDB@NDB(SYSTEM)
# vemos los db:
select * from "SYS"."M_DATABASES";
#1. Creamos la db
CREATE DATABASE E14 ADD 'xsengine' ADD 'scriptserver' SYSTEM USER PASSWORD Test1234;
#2. Ahora paramos la base de datos para poder restaurarla:
ALTER SYSTEM STOP DATABASE E14;
#3. Verificamos que la db E14 este detenida:
select * from "SYS"."M_DATABASES";
#4.Recuperar la base de datos:
testv10:/backup/data/DB_E14/data/DB_E14 # pwd
RECOVER DATA FOR E14 USING FILE ('/backup/data/DB_E14/data/DB_E14/20260329_192502_E14_COMPLETE_DATA_BACKUP') CLEAR LOG;
#5. Verificar el estado de las base de datos nuevamente, y si el E14 no estuviese iniciado, debemos iniciarlo:
select * from "SYS"."M_DATABASES"
ALTER SYSTEM START DATABASE E14;  ---> !!!! A veces no es necesario, la db ya esta activa !!!!

# Session : E14@NDB(SYSTEM)
#1. Workaround for Exporting/Importing:
ALTER SYSTEM ALTER CONFIGURATION ('indexserver.ini', 'system') set ('import_export', 'enable_history_table_import_export') = 'true' with reconfigure;


================================================ En el MT testv10 exportar, comprimir, up to sftp ============================================

#Into testv10 to upload the schema to the SFTP

cd /tmp && ls -lha
mkdir esquema_01/ TAR_ZIP_GZ/
chmod -R 777 esquema_01/ TAR_ZIP_GZ/
chown -R ndbadm:sapsys esquema_01/ TAR_ZIP_GZ/ && ls -lha

#SQL Varibles (SYSTEM)
dbSql="/hana/shared/NDB/HDB00/exe/hdbsql"
dbInstance="00"
dbHost="127.0.0.1"
dbTenant="E14"
dbUser="B1SYSTEM"
dbPass="GPu7GU5qe6nfTg4J"

#Test DB
"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" 'select * from "SYS"."SCHEMAS";'
  
# Export the schema
"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" 'export 'SBO_BKGS_DEV '."*" as binary into '\'/tmp/esquema_01\'' with ignore existing threads 10;'


# Compress schemas and save on folder
testv10:/tmp #
tar -czvf TAR_ZIP_GZ/SBO_BKGS_DEV.tar.gz --transform 's/^esquema_01/SBO_BKGS_DEV/' esquema_01/
# verificación que la compresion se haya completado sin problemas:
tar -tzf TAR_ZIP_GZ/SBO_BKGS_DEV.tar.gz | head -5
# damos permisos al comprimido:
chmod -R 777 esquema_01/ TAR_ZIP_GZ/
chown -R ndbadm:sapsys esquema_01/ TAR_ZIP_GZ/

# Upload to the SFTP
sftp -P 2022 c.pecho@files.dcdus.privatcloud.biz
C4!qE0e]cVFy&$m
cd /ramo/APC
ls -lha
get 080SBOMAQEMAG25072025.tar.xz
bye

# Delete the non necessary files
cd /tmp && ls -lha && rm -rf esquema_01/ TAR_ZIP_GZ/ && ls -lha

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