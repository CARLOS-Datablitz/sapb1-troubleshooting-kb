Add & remove users process:
Ch@ng4MeNow!


IMPORTANTE:
!! todos los tickets donde dice que se crea usuario o se agregan recursos son Billable_WT

(Ejemplo: Allpro OU/Tampa/Users)
DC ----> Tools/Users and Devices AD
			----> Copy one user.
* TS01 ---> 25 User per server

Esto te da el número de usuarios habilitados en el AD:
Get-ADUser -Filter {Enabled -eq $true} | Measure-Object

Get-ADUser -Identity "lissa.nelson" -Properties Enabled | select Name, SamAccountName, Enabled


***** REMOVE*****
Verificar si un usuario esta disable:

Get-ADUser -Identity "jonathan.scherer" -Properties Enabled | Select-Object Name, Enabled
Get-ADUser -Identity "Nathan.Galloway" -Properties Enabled | Select-Object Name, Enabled


----------------------------------------------
add_new_users:
referenced ticket: 
Minera Samanco:iSystems#99166571

1. Ver numero de usuarios(activos y no activos) en el DC:
		- Ver el archivo en esta carpeta llamado: dc_check_user.txt

3. Check licences numbers:
	Licenias:RDS(Windows Server), las licencias son por usuario.
		- Tools/Remote Desktop Services/Administrador de Licencias
			RDS01:Aquí vemos el numero Total de licencias: Disponible + Emitidas

2. Ver recursos en servidor RDS:
   1. Zabbix ---> Aquí vemos el USO del RDS, y de los demas servers, los recursos(CPU,Memory,HD) y lo comparamos con la tabla(Tabelle RDS).
   	1.1 ---> los recursos tienen que ser suficientes para soportar los usuarios de cliente.
   2. Administrador de tareas del RDS ---> Aquí vemos la cantidad de cpu cores y la ram.
   3. PROXMOX ---> Aquí vemos el USO y la CAPACIDAD de los recursos de los servidores.

----------------------------------------------
Dear TacticaIT team,

We have added a new user for the client Ecolimpio. The user credentials are as follows:

Username: user14

Password: <check the link>

Please verify that the new user's access is functioning correctly and let us know if any adjustments are needed.



This is to confirm that Raymond Ramos has been successfully removed from access to ALLSTARTS systems.
Please let me know if you need anything further.

Se han agregado dos nuevos usuarios, User9 y User10; encontrará la contraseña en el siguiente link:
Por favor indicarnos el día y hora en la que podamos reiniciar el servidor RDS a fin de aumentar los recursos necesario.
Quedamos pendientes a su confirmación.

Saludos cordiales,

----------------------------------------------
Se han agregado un nuevo usuario, user13; encontrará la contraseña en el link de abajo, cambiar la contraseña luego del primer acceso.
Por favor, verifiquen que el acceso del nuevo usuario esté funcionando correctamente y hágannoslo saber si se necesita algún ajuste.


A new user, user13, has been added. You will find the password in the link below; please change the password after the first login.
Please verify that the new user’s access is working correctly and let us know if any adjustments are needed.
Additionally, we would like to inform you that it is necessary to increase the resources of the RDS server. Please let us know the date and time when we can perform this task.

----------------------------------------------
===> Forward & Set to internal

j.kamphof
n.dammer

Hi, Jessica, hi Nicole, we've added a new user for the client ALLPRO.

Hi Jessica, hi Nicole,
I’ve completed the removal of Nathan Galloway from the ALLPRO systems, per the customer’s request.

-------------------------- TEST --------------------
RdsHtml5

https://rds01.farmak.privatcloud.biz:1238/rdweb/webclient/index.html


ALLPRO:

https://ap-rds.allpro.privatcloud.biz/rdweb/webclient/index.html
lissa.nelson@allprocorp.com
Kevin.Carter@allprocorp.com
alan.kmiecik@allprocorp.com


Alan Kmiecik has been added to ALLPRO Systems; you will find the password at the following link: 


Please verify that the new user access is working correctly and let us know if any adjustments are required.
Alan Kmiecik has been added to ALLPRO Systems.

IMPORTANTE:
!! todos los tickets donde dice que se crea usuario o se agregan recursos son Billable_WT


------ PROBAR NUEVO USUARIO CREADO --------
RdsHtml5:
https://rds.mcbauchemie.privatcloud.biz:10106/rdweb/webclient/index.html

Cuenta de usuario recien creardo:

!!!!! IMPORTANTE EN ALGUNOS CASOS EN EL CAMPO USER SOLO SE COLOCA : user13 (Sin la parte del dominio o correo)
user13@mcbauchemie.privatcloud.biz


https://rds.ecolimpio.privatcloud.biz:10039/rdweb/webclient/index.html

user18@ecolimpio.privatcloud.biz
Ch@ng4MeNow!