#1st Run
screen -dRR
cd /usr/sap/SAPBusinessOne/B1_SHF/ && ls -lha
mkdir Omaha/ && ls -lha
cd Omaha
mkdir Word/ Excel/ Pictures/ Attachments/ Extensions/ XML/
chmod -R 777 Omaha/ && ls -lha
chown -R b1service0:b1service0 Omaha/ && ls -lha


#2nd run
cd /mnt
mkdir Attachments/
chmod -R 777 Attachments/
chown -R b1service0:b1service0 Attachments/
ls -lha && df -h

#this is the only one that you execute
echo '//sld/B1_SHF/Omaha/Attachments       /mnt/Attachments       cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0'>>/etc/fstab

#check the fstab file and modify it if necessary 
cat /etc/fstab
vim /etc/fstab
mount -a -v
df -h | grep Attachments


iSystems#99125266

===============FIN=====================

Ruta:
sles:/usr/sap/SAPBusinessOne/B1_SHF/O

====================================




A mount point has been created on that server, so that it can be configured in SAP for better organization.

Please configure the paths as follows within the general settings:

Attachment folder: \\sles\B1_SHF\Omaha\Attachments
EXCEL folder: \\sles\B1_SHF\Omaha\Excel
Word folder:\\sles\B1_SHF\Omaha\Word
Pictures folde: \\sles\B1_SHF\Omaha\Pictures
Extensions folder: \\sles\B1_SHF\Omaha\Extensions
XML folder: \\sles\B1_SHF\Omaha\XML


Please verify that everything is working as expected, and let us know if any adjustments are required.
