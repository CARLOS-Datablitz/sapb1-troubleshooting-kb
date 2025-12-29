
El Attachments se configura generalmente en el SLD,  el attachments se monta donde esta la instalacion del SAP, si en un sles esta pues va en /usr/sap/....
en el sld siempre encontrarars esa ruta /usr/sap.

TICKET DE REFERENCIA: iSystems#99185181, mejor ticket de referencia: iSystems#99196407

Nota! : No configurar dos folderes apuntando al mismo folder "Attachment", generará duplicidad y sobreescritura de datos.

==============REINICIO DE SLD ==================
Al reiniciar SLD:
volver a montar las carpetas:
mount -a -v
Si falla entonces:
sld:/tmp # vim /etc/samba/smb.conf > guest= Yes(por defecto se vuelve a No despues del reinicio)
Verificar si esta montado:
sld:/tmp # cat /etc/fstab

=====================================
Ticket de referencia: iSystems#99168105
iSystems#99160828  ---> Jack
1. Verificar en SLD/SLES si cifs-utils está instalado
   rpm -qa | grep cifs-utils
   cifs-utils-6.9-150100.5.18.1.x86_64
   - Si no devuelve nada, instalar junto con samba-client:
     sudo zypper install cifs-utils samba-client

2. Crear punto de montaje
   sudo mkdir -p /mnt/Attachments
   sudo chown b1service0:b1service0 /mnt/Attachments
   - Usar A mayúscula en Attachments para que sea coherente con el nombre remoto.

3. Agregar la entrada a /etc/fstab
   - Antes de agregar, revisar que no exista ya una línea similar:
     grep Attachments /etc/fstab

   - Si no existe, agregar:
     echo '//sles/B1_SHF /mnt/Attachments cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,prefixpath=Attachments,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0' | sudo tee -a /etc/fstab

   Notas:
   - "guest" funcionará sólo si el recurso compartido permite acceso sin credenciales.
   - Si falla, usar credenciales: credentials=/ruta/.smbcredentials
   - prefixpath=Attachments debe ir exactamente como está en el servidor (A mayúscula).

4. Aplicar y montar
   sudo systemctl daemon-reload
   sudo mount -a
   - Si mount -a devuelve error, verificar acceso al servidor:
     ping -c 3 sles
     smbclient -L //sles -N

5. Verificar montaje
   ls -l /mnt/Attachments
   df -h | grep Attachments
   - Si se ve el contenido esperado y df muestra //sles/B1_SHF, el montaje fue exitoso.


====================================

# Attachment Example Rheinperchemie
ordener
# 10.2.89.106b1_shfSAP_B1Attachments ruta en Windows donde esta el B1:
\\sld\B1_SHF\CASTELLAnexos

# ssh root in sld
screen -dRR
sld:~ # cd /usr/sap/SAPBusinessOne/B1_SHF/ && ls -lha
mkdir -p CASTELLAnexos
chmod -R 777 CASTELLAnexos
chown -R b1service0b1service0 CASTELLAnexos

cd mnt
mkdir -p CASTELLAnexos
chmod -R 777 CASTELLAnexos
chown -R b1service0b1service0 CASTELLAnexos && ls -lha

echo 'sldB1_SHFCASTELLAnexos                   mntCASTELLAnexos        cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0'  etcfstab

cat etcfstab-
# vim etcfstab

mount -a -v

df -h
df -h  grep CASTELLAnexos


=====================================


