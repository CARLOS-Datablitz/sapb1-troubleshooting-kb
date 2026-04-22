
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

===================== Cambiar/importar los certificados en el RDS ===========================
- Tener los certificados en el C:\ del RDS de cliente, borrar los certificados antiguos.

1#
En el Server Manager Dashboar> Remote Destop Services/Overview/DEPLOYMENT OVERVIEW > TASKS/Edit Deployment Properties
																								->Certificates ->
-> - RD Connection Broker - Enable Signing --> Select existing certificate --> Choose from RDS C:\ .pfx Password: sapB1iP --> Check: "Allow the certicate to be ...." --> Apply(NO OK es al ultimo) --> Next
   - RD Conecction Broker - Publishing
   - RD Web Access
   - RD Gateway
   --> OK
  
2#
See certificate_rds.ps1 file on this folder, edit it with the data of customer env.
run the above script on the PowerShell ISE as administrador


========================================================================================

On your PC´s browser:
A: RdsLogin: https://rds.bodenfachmarkt.privatcloud.biz:10089/rdweb
B: RdsHtml5: https://rds.bodenfachmarkt.privatcloud.biz:10089/rdweb/webclient/index.html

1. Check date of expiration or validation: browser> La conexión es segura/El certificado es valido > Período de validez
2. Desde A: RDS Credentials/ Click SAP(it will downloaded)/execute it / RDS credentials > Conexión a Escritorio Remoto(your should be in the rds server).
3. Desde B: RDS Credentials/ Click SAP > Direct conecction through web browser < ERROR (error esperado)> Seguir en paso C:
5. Luego de editar y ejecutar el scrip se debe probar la conexión en el link pero en modo oculto ya que se quedan guardada la sesión fallída en las cookies.

Escritorio remoto desde tu PC local:
Windows + R: mstsc /v:10.2.200.85/admin
