iSystems#99168619
Creación de una base de pruebas a partir de la base productiva con corte al 13/08/2025, ya que el cliente necesita realizar pruebas de flujos internos antes de ejecutarlas en el entorno productivo.

# Ticket: iSystems#99168619
  # Tasks:
  # export/Import the schema: SBO_BUYANDGO >> BK_BYG_130825 
  # For RAMO - BUY&GO - / dctpamt090 - IP/10.3.90.2
  # Date: 14/08/2025
  # Tenant: E01

=================================================
1. Preparar el entorno en el sles, HANA, HANA-MT:
  # Empecemos.....
screen -dRR
cd /tmp && ls -lha
mkdir dbnvr
chmod -R 777 dbnvr/
chown -R ndbadm:sapsys dbnvr/ && ls -lha

=================================================
2. Variables de entorno:
	-------------------   
 2.1 Sacar información de las variables:
	sld:~ # 
cat Desktop/SAP_Configuration.txt
 2.2 Ingresar las variables en el sles:/tmp #
 	# Varibles HANASQL (B1SYSTEM)
    # en donde confirmo la ruta o parametro de la siguiente línea.?
dbSql="/hana/shared/NDB/hdbclient/hdbsql"
dbInstance="00"
dbHost="127.0.0.1"
dbTenant="E01"
dbUser="B1SYSTEM"
dbPass="q6xS3JFP51Mb"
-------------------   
  # ver las db o schemas: entrar al rds/Business One 64 bits

  # Testear la base de datos: NDB
  sles:/tmp #
"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" 'select * from "SYS"."SCHEMAS";'

  # Export the schema
   sles:/tmp #
"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" 'export 'SBO_BUYANDGO'."*" as binary into '\'/tmp/dbnvr\'' with ignore existing threads 10;'

  # Check
ls -lha /tmp/dbnvr/export
  # Done Export
  [ SBO_BUYANDGO] ---> 0 rows affected (overall time 49.231266 sec; server time 49.231005 sec)


  # import and rename the schema
"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" 'import 'SBO_BUYANDGO'."*" as binary from '\'/tmp/dbnvr\'' with ignore existing threads 10 rename schema "SBO_BUYANDGO" to "BK_BYG_130825";'

  # Done import
  [ SBO_DISTRIBUIDORA <=> ZZ_DISTRIBUIDORA ] --->   Warning: * 1347: Not recommended feature: Using SELECT INTO in Scalar UDF SQLSTATE: HY000
                          0 rows affected (overall time 32.759035 sec; server time 32.758837 sec)

  # Testear la base de datos: NDB
"$dbSql" -i "$dbInstance" -d "$dbTenant" -n "$dbHost" -u "$dbUser" -p "$dbPass" 'select * from "SYS"."SCHEMAS";'    #--> SBO_DRISTIBUIDORA + ZZ_DISTRIBUIDORA


  =========================  FIN =================
