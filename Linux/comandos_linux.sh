------------------------------------
#buscar en el directorio actual(.) el archivo
~$ find . -name <filename*>

which <program name eg. file>
/usr/bin/file
file
echo $PATH

------------------------------------
#pwd como variable:
$ cat $(pwd)/*

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

