# Ticket:Systems#99167736
Client: Releng
Multitenant: 10.3.92.2
SLD: 10.3.92.250

sld:~ # cat Desktop/SAP_Configuration.txt
#SQL Varibles (B1SYSTEM)
dbSql="/hana/shared/NDB/hdbclient/hdbsql"
dbInstance="00"
dbHost="127.0.0.1"
dbTenant="E09"
dbUser="B1SYSTEM"
dbPass="9HNxHs0u1Vs6pSeX"

1.2 test de acceso en el multitenat:
"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" 'select * from "SYS"."SCHEMAS";'

1.3 crear carpeta donde se va a guardar la db para la exportación:
# Begining in the hana
df -h
screen -dRR
cd /tmp && ls -lha
mkdir LIONPOWERPILOT_ZIP/ lionpower/
chmod -R 777 LIONPOWERPILOT_ZIP lionpower/
chown -R ndbadm:sapsys LIONPOWERPILOT_ZIP/ lionpower/ && ls -lha

#Export the schema

"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" 'export 'LIONPOWERPILOT'."*" as binary into '\'/tmp/lionpower\'' with ignore existing threads 10;'


#Tar and move to another folder
tar -czf LIONPOWERPILOT_ZIP/i2025_1289363_1289363.tar.gz lionpower/

# Upload to the SFTP
#Correr el comando en el directorio donde se encuentra el archivo
sftp -P 2022 c.pecho@files.dctpa.privatcloud.biz
C4!qE0e]cVFy&$m
cd /xplora/releng/
mkdir backup_11-08-2025
cd backup_11-08-2025
put SBO_PROD_XH.tar.gz  ----> copiar ruta para compartir con cliente eg: /xplora/Releng/backup_11-08-2025/SBO_PROD_XH.tar.gz
bye

# Delete and list the non necessary files in one line
cd /tmp && ls -lha && rm -rf one/ PAS/ && ls -lha




