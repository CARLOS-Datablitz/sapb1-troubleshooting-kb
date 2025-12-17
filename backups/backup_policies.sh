
Backup Policies
iSystems#99195436, iSystems#99192414


1) Dracool have asked us what the backup and retention policies are with iSystems. I wanted to reach out and see if there was any documentation on it?
Well about this in their SOW (Internal Document) they have a retention backup of their DB of 7 days, that is stored in our DC in Tampa with replication in Dusseldorf (Germany), this is with respect of the Database, because is part of a Multitenant system.
And with respect to the backups of the VM (virtual machines) we have backups from 3-4 days ago per VM.

2)  What (if any) options are there for them to be able to download database backups?
They can request us their DB we can provide them but is not possible to them to have acces to our Backup cloud system.


================================================

Cuando tu te refieres ha:
- ¿O sea que el servidor del cliente se encuentra dentro de Tampa, florida?
Segun veo tu mensaje fue para "tacticademo.privatcloud.biz", y tacticademo son ustedes, es un entorno para ustedes, cuando dices: el servidor del cliente, ¿A que cliente haces referencia?

- ¿Podrías compartirme también cada cuanto se realizan los respaldos de las bases?
- Dependiendo de cada multitenant o single tenant, el respaldo en linux se hace a travez de un script que se ejecuta en background, lo que hace es hacer un full backup de la base de datos, comprimirla, y subirla un servidor donde se guardan estos respaldos.
El tiempo es configurable, si tu pregunta es para "tacticademo" el script se ejecuta para el multitenant donde esta a las 19:25PM todos los dias.

- ¿De que tipo son los respaldos que se hacen?
Hay respaldos que se hacen a las maquinas virtuales, todos los dias a las 9:00PM y en los caso de hana se ejecuta un script.

- ¿Por cuanto tiempo guardan esos respaldos?
Para el del multitenant donde esta alojado "tacticademo" que es por lo cual veo que estas preguntando, el perido de retencion que tiene configurado actualmente es de: 9 dias en lo que es base de datos y maquinas virtuales 3-4 dias atras.

