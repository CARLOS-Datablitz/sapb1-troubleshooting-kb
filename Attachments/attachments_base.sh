===============================================================================================================================================================
# Attachment Example Rheinperchemie
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
mkdir -p Common\Attachments
chmod -R 777 Common/
chown -R b1service0:b1service0 Common/ && ls -lha

echo '//sld/B1_SHF/Common/Attachments/                  /mnt/Common/Attachments        cifs rw,guest,uid=b1service0,gid=b1service0,vers=3.0,iocharset=utf8,file_mode=0777,dir_mode=0777,noperm,nounix,x-systemd.automount 0 0'>>/etc/fstab

cat /etc/fstab
# vim /etc/fstab
mount -a -v
df -h
df -h | grep Common


