
--- ver el usuario de HANA ----- ver el usuario de HANA ----
sles: ~# cat /etc/passwd
ndbadm:xxxx SAP HANA Database System Administrator
sles: ~# su - ndbadm
ndbadm@sles:/usr/sap/NDB/HDB00> ls -lha

# Apagar la db HANA:
sles: ~# su - ndbadm
ndbadm@sles:/usr/sap/NDB/HDB00> ./HDB stop
# Apagar el servidor(sles) desde el PROXMOX, para tomar un snapshot
# Luego reiniciar el servidor y ver que los servicios levantan
-- Desde el PROXMOX una vez que la VM(sles) este apagado se debe tomar un snapshot ---
# ver los servicis levantar:
sles: ~# htop

--- SLD ---

systemctl status sap*:
sldwcms:~ # systemctl status sap*
sldwcms:~ # systemctl stop sapb1servertools.service

Restart linux:
systemctl reboot

systemctl poweroff -----> !!!! CUIDADO SE PIERDE GESTION !!!!

The servers have been restarted.

Nota: A veces toma mas de 7 minutos que el servicio sapb1servertools levante, mientras que el servicio sapinit.service levanta casi inmediatamente.
