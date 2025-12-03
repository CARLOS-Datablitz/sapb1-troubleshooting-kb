

EN EL SLD:
    
#1st Run
screen -dRR
cd /usr/sap/SAPBusinessOne/B1_SHF/ && ls -lha
mkdir Attachments / && ls -lha
chmod -R 777 Attachments/ && ls -lha
chown -R b1service0:b1service0 Attachments/ && ls -lha


#2nd run
cd /mnt
mkdir Attachments/
chmod -R 777 Attachments/
chown -R b1service0:b1service0 Attachments/
ls -lha && df -h

#this is the only one that you execute
echo '//sld/B1_SHF/Attachments       /mnt/Attachments       cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0'>>/etc/fstab

#check the fstab file and modify it if necessary 
cat /etc/fstab
#vim /etc/fstab
mount -a -v
#succesfull succesfully mounted
df -h && df -h | grep Attach*



