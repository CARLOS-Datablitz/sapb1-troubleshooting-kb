Production: \\10.2.94.106\b1_shf\Exdoc\Attachments\Anexos\
Testing: \\10.2.94.106\b1_shf\Exdoc\Attachments\Anexos\TESTES\

#1st Run
screen -dRR
cd /usr/sap/SAPBusinessOne/B1_SHF/Exdoc/Attachments/Anexos && ls -lha
chmod -R 777 Anexos/ 
chown -R b1service0:b1service0 Anexos/
cd Anexos
chmod -R 777 TESTES/ 
chown -R b1service0:b1service0 TESTES/

#2nd run
cd /mnt
mkdir AttachmentsPR/ AttachmentsTST/
chmod -R 777 AttachmentsPR/ AttachmentsTST/
chown -R b1service0:b1service0 AttachmentsPR/ AttachmentsTST/
ls -lha && df -h

# echo '//sld/B1_BHF/ONEID/Attachments       /mnt/Attachments       cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0'>>/etc/fstab

#this is the only one that you execute
echo '//sld/B1_SHF/Exdoc/Attachments/Anexos     /mnt/AttachmentsPR       cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0'>>/etc/fstab
echo '//sld/B1_SHF/Exdoc/Attachments/Anexos/TESTES     /mnt/AttachmentsTST       cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0'>>/etc/fstab

#check the fstab file and modify it if necessary 
cat /etc/fstab
vim /etc/fstab
mount -a -v
df -h | grep Attachments