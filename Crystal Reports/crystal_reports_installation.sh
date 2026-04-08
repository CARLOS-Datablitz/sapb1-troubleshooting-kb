

1. Revisar en el Fenruz/Crystal Reports Matrix
	- Tengo cuenta SAP for Me para ver la version de SAP Business One eg. 10.0_SP 2505 // 10.0_SP2405HF1
	- Revisar en \\sld\B1_SHF\<carpeta_version> ---> version(10.0_SP2405HF1)
	- Ubicar y descargar de aquí la version correcta: https://me.sap.com/notes/2329487/E   ----> !!!! IMPORTANTE descargar la version correcta !!!!
		---> Click 3100066  ---> SAP One Support Launchpad Descargas de software ---> SAP Business One/SAP Business One Products ---> SAP CRYSTAL REPORTS FOR B1
			---> CRYSTAL REPORTS 2020 FOR B1 ---> INSTALLATION ---> SAP Crystal Reports 2020 SP4 P10 for SAP Business One ZIP

	
2. Una vez que tenemos el .zip con el instalador de Crystal Report lo colocamos en Downloads(RDS), y desde ahí copiamos al servidor SLD en la ruta:
		SLD Server:
		\\sld\B1_SHF
				--> Creamos una carpeta desde el RDS: Red\\sld\B1_SHF\<CR2020_SP4_P10>(version del CR)  ---> luego en el linux le damos el permiso(paso 3.)
				mueves el .zip desde Downloads hasta aqui y la descomprimes.
					---> Crear un .txt de nombre VERSION.txt
					
3. En el SLD(Linux):
sld:~ # cd /usr/sap/SAPBusinessOne/B1_SHF/
# chmod -R 777 <CR2020_SP4_P10>/
# chown -R b1service0:b1service0 <CR2020_SP4_P10>/

# Verificar que la carpeta <CR2020_SP4_P10> este en VERDE

4. Install SAP Crystal Reports:
Desde servidor Windows (rds, adm, app, etc):
   \\sld\B1_SHF\<CR2020_SP4_P10>\ ejecutamos como "administrador" setup.exe ---> Next ...> Finished
   
5. Run the SAP Crystal Reports integration script (CR Integration):
	\\sld\B1_SHF\CR_Integretion:
		---> SAP Business One Crystal Report Integration.exe ## tenemos que instalarlo

6. Crear acceso directo al escritorio:
	Buscar la aplicacion SAP Crystal Report for SAP Business ---> Abrirla para que carguen por primera vez
	Copiar el icono de la aplicacion y arrastralo a una carpeta temporal(Descargas/Downloads), y luego Run/Ejecutar: %Public%\Desktop  ---> se abrirá otro Panel --->
		---> y copiar/arrastrar el icono desde Downloads al nuevo Panel.  ---> Esto mostrará el icono en el escritorio para todos los usuarios.
	Borrar el icono que se encuentra en Descargas/Downloads.
7. Finalmente:
	- Abrir icono de escritorio como administrador y luego como usuario normal.
	- Enviar SS de Server Manager y CR a cliente.
