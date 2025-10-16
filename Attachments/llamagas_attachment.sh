# EN EL SLD

#1st Run
screen -dRR

#2nd run
cd /mnt
mkdir Attachments/
chmod -R 777 Attachments/
chown -R b1service0:b1service0 Attachments/
ls -lha && df -h

#this is the only one that you execute NOTA: he agregado ,_netdev 0 0, para que systemd espere a la red.
echo '//sld.llamagas.nubeprivada.biz/Attachments       /mnt/Attachments       cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount,_netdev 0 0'>>/etc/fstab

#check the fstab file and modify it if necessary 
cat /etc/fstab
vim /etc/fstab
mount -a -v # Este comando vuelve a montar todas las entradas del /etc/fstab inmediatamente.
df -h | grep Attachments



