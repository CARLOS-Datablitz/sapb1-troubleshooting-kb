

El Attachments se configura generalmente en el SLD,  el attachments se monta donde esta la instalacion del SAP SAPBusinessOne Server, si en un sles esta pues va en /usr/sap/....
en el sld siempre encontrarars esa ruta /usr/sap/B1_SHF.

!!!!! IMPORTANT NOTES !!!!!

Caution:
The name of the mount point must not contain underscores (_).
Correct example: /mnt/sbomailer

!!!!! IMPORTANT NOTES !!!!!

Incorrect example: /mnt/sbo_mailer

!!!!! IMPORTANT NOTES !!!!!


/B1_SHF===========================================  LINUX   ==================================================================================

Attachment Example Rheinperchemie
ordner:
\\sld\b1_shf\Common\Attachments\

# ssh root@sld
zypper install -y tree
screen -dRR
cd /usr/sap/SAPBusinessOne/B1_SHF/
mkdir -p Common/Attachments/
chmod -R 777 Common/
chown -R b1service0:b1service0 Common/

cd /mnt
mkdir -p Common/Attachments
chmod -R 777 Common/
chown -R b1service0:b1service0 Common/ && ls -lha

echo '//sld/B1_SHF/Common/Attachments/      /mnt/Common/Attachments        cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0'>>/etc/fstab

cat /etc/fstab
# vim /etc/fstab
mount -a -v
df -h
df -h | grep Common
=========================================== Windows   ===========================================================================

# Attachment SLD <====> Windows
ordner:
\\sld\b1_shf\Attachments\  ----> \\RDS\RepositorioSAP(Windows)[darle todos los permisos a esta carpeta para los usuarios que van a acceder, local o dominio]
[Esta ruta es sld linux]		 [Esta ruta es la del rds]


# ssh root@sld
zypper install -y tree
screen -dRR
cd /usr/sap/SAPBusinessOne/B1_SHF/
mkdir -p Common/Attachments/
chmod -R 777 Common/
chown -R b1service0:b1service0 Common/

cd /mnt
mkdir -p Common/Attachments
chmod -R 777 Common/
chown -R b1service0:b1service0 Common/ && ls -lha

echo '//sld/B1_SHF/Common/Attachments/                  /mnt/Common/Attachments        cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0'>>/etc/fstab

cat /etc/fstab
# vim /etc/fstab
mount -a -v
df -h
df -h | grep Common

============================== ACTION =============================

Testing :    \\10.2.94.106\b1_shf\Exdoc\Attachments\Anexos\TESTES\
Production : \\10.2.94.106\b1_shf\Exdoc\Attachments\Anexos\

# ssh root@sld
screen -dRR
cd /usr/sap/SAPBusinessOne/B1_SHF/
mkdir -p Exdoc/Anexos/TESTES/
chmod -R 777 Exdoc/
chown -R b1service0:b1service0 Exdoc/

cd /mnt
mkdir -p Exdoc/AttachmentsAnexos/
chmod -R 777 Exdoc/
chown -R b1service0:b1service0 Exdoc/ && ls -lha


echo '//10.2.94.106/B1_SHF/Exdoc/Attachments/Anexos/               /mnt/Exdoc/AttachmentsAnexos        cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0'>>/etc/fstab

cat /etc/fstab
# vim /etc/fstab
mount -a -v
df -h
df -h | grep Exdoc

===================== Attachment basico ===================

# ssh root@sld
zypper install -y tree
screen -dRR
cd /usr/sap/SAPBusinessOne/B1_SHF/
mkdir -p Attachments/
chmod -R 777 Attachments/
chown -R b1service0:b1service0 Attachments/

cd /mnt
mkdir -p Attachments/
chmod -R 777 Attachments/
chown -R b1service0:b1service0 Attachments/ && ls -lha

echo '//sld/B1_SHF//Attachments/                  /mnt/Attachments        cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0'>>/etc/fstab

cat /etc/fstab
# vim /etc/fstab
mount -a -v
df -h
df -h | grep Attachments

Get-ADUser -Identity "tim.jeffries" -Properties Enabled | Select-Object Name, Enabled
