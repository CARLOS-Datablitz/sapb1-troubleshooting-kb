------------------------------------
#buscar en el directorio actual(.) el archivo
~$ find . -name <filename*>

which <program name eg. file>
/usr/bin/file
file
echo $PATH
# buscar un archivo
$ updatedb
$ locate new.txt



------------------------------------
#pwd como variable:
$ cat $(pwd)/*
$ cat $(find . -name -file07)
------------------------------------
#ver archivos ocultos: los recursos que empiezan por un . no se ven ka menos que uses:
$ ls -a inhere/

------------------------------------
# xargs: en forma paralela ejecutar comandos en base al output de un comando ejecutado anteriormente:
$ find . -name .hidden | xargs cat
$ find . -type f | xargs grep "leaving"
------------------------------------
# mostrar solo unas lineas del output de cat
$ cat /etc/passwd | head -n 2
$ cat /etc/passwd | tail -n 2
$ cat /etc/passwd | awk 'NR==2'
------------------------------------
$ cat /usr/share/rockyou.txt | grep ^hola # busca explicitamente todas las palabras que inican con hola

------------------------------------
#ver interfaces de red cableado y wifi
$ ifconfig
$ iwconfig

------------------------------------
#ver puertos activos
$ netstat

------------------------------------
#ver la tabla de ruteo
$ route

------------------------------------
#ping result to ip.txt
$ ping -c 5 192.168.0.124 > ip.txt

------------------------------------
#ipsweep.sh
#!/bin/bash
for ip in `seq 1 254`; do
	ping -c 1 $1.$ip | grep "64 bytes" | cut -d " " -f 4 | tr -d ";" &
done
# execute: $ ./ipsweep.sh 192.168.1
# then: ./ipsweep.sh 192.168.1 > iplist.txt
# nmap: $ for ip in $(cat iplist.txt); do nmap -p 80 -T4 $ip & done
------------------------------------


------------------------------------





