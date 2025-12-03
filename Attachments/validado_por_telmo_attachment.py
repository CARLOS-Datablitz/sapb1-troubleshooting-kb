

EN EL SLD:
    
#1st Run
screen -dRR
cd /usr/sap/SAPBusinessOne/B1_SHF/ && ls -lha
mkdir Attachments/ && ls -lha  # ----> "Attachments2" se cambia por el nombre que quiere el cliente, sino te indica debe preguntarle(sld:/usr/sap/SAPBusinessOne/B1_SHF/Attachments # ll).
chmod -R 777 Attachments/ && ls -lha
chown -R b1service0:b1service0 Attachments/ && ls -lha


#2nd run
cd /mnt
mkdir Attachments2/   # ----> Cada carpeta que se tiene que montar tiene que tener un nombre diferente
chmod -R 777 Attachments2/
chown -R b1service0:b1service0 Attachments2/
ls -lha && df -h

#this is the only one that you execute
echo '//sld/B1_SHF/Attachments/PROD      /mnt/Attachments2       cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0'>>/etc/fstab

#check the fstab file and modify it if necessary 
cat /etc/fstab
#vim /etc/fstab
mount -a -v
#succesfull succesfully mounted
df -h | grep Attach*

    
NOTAS: Porque el nombre "Attachments" en el #1st Run, es porque es el nombre que cliente quiere que se coloque eg: \\sld.raceworks.privatcloud.biz\B1_SHF\Attachments\
iSystems#99187637
NOTA IMPORTANTE: Asegurarte que la carpeta tenga los permisos.
