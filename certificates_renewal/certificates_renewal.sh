
PKI Cert:
sapB1iP 
!!!! IMPORTANT STEP FIRST: Once created find/put it here: C:\Users\c.pecho\iSystems GmbH\iSystems Support - SAP\Customers\+++Internal\Support\Microsoft\Pki
then copy to ISCDE folder and edit the name(remove []).


=========================
All work is on the RDS serveer:
1. Paste on the Desktop the 02 certicates .pfx and .cer
2. Se pega los dos archivos de arriba en C:\


En el Server Manager Dashboar> Remote Destop Services/ DEPLOYMENT OVERVIEW > TASKS/Edit Deployment Propertie

En el Server Manager Dashboar> Remote Destop Services/ DEPLOYMENT OVERVIEW > TASKS/Edit Deployment Properties>Certificates:
RD Connection Broker - Enable Signing
RD Connection Broker - Publishin
RD Web Access
RD Gateway

1. Select existing certificate...
/second option: > chose the .pfx from C:\
2. Password: sapB1iP
3. Check the box.


On your PC´s browser:
A: https://rds.bodenfachmarkt.privatcloud.biz:10089/rdweb
B: https://rds.bodenfachmarkt.privatcloud.biz:10089/rdweb/webclient/index.html

1. Check date of expiration or validation: browser> La conexión es segura/El certificado es valido > Período de validez
2. Desde A: RDS Credentials/ Click SAP(it will downloaded)/execute it / RDS credentials > Conexión a Escritorio Remoto(your should be in the rds server).
3. Desde B: RDS Credentials/ Click SAP > Direct conecction through web browser < ERROR (error esperado)> Seguir en paso C:

Paso C:
editar el script error_html_certificate_base.txt
Nota: el puerto esta en B´s link
Ctrl + h para sustituir

4. Ejecutar el script en un PowerShell ISE, como administrador, 
5. Luego de editar y ejecutar el scrip se debe probar la conexión en el link pero en modo oculto ya que se quedan guardada la sesión fallída en las cookies.


