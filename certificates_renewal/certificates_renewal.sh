
PKI Cert:
sapB1iP 
!!!! IMPORTANT STEP FIRST: Once created find/put it here: C:\Users\c.pecho\iSystems GmbH\iSystems Support - SAP\Customers\+++Internal\Support\Microsoft\Pki
then copy to, using One Command, ISCDE folder and edit the name(remove []).


==============  X Certificate and Key managment  ===========
All work is on the RDS serveer:
X Certificate and Key managment/certicates/<Certificate_Name>/Export
1. Paste on the Desktop the 02 certicates PKCS#12(*.pfx) and DER(*.cer), posición 7 y 4 del desplegable.
2. Se pega los dos archivos de arriba en C:\
3. Te va a pedir credenciales: User: sapB1iP passw:
4. Luego copy to, using One Command, ISCDE folder de cliente donde esta su Server Questions.xlsx, and edit the name(remove iSystems[]).
and then to Desktop/Downloads and from here move to the RDS C:\

===================== Cambiar los certificados en el RDS ===========================

En el Server Manager Dashboar> Remote Destop Services/Overview/DEPLOYMENT OVERVIEW > TASKS/Edit Deployment Propertie
																								->Certificates ->
-> - RD Connection Broker - Enable Signing --> Select existing certificate --> Choose from RDS C:\ .pfx Password: sapB1iP --> Apply --> Next
   - RD Conecction Broker - Publishing
   - RD Web Access
   - RD Gateway
   

RD Connection Broker - Enable Signing
RD Connection Broker - Publishin
RD Web Access
RD Gateway

1. Select existing certificate...
/second option: > chose the .pfx from C:\
2. Password: sapB1iP
3. Check the box.

========================================================================================

On your PC´s browser:
A: h
ttps://rds.bodenfachmarkt.privatcloud.biz:10089/rdweb
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


