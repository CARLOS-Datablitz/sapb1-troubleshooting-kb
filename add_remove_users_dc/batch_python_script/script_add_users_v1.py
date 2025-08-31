def generar_encabezado(dcip, rdd, rnb, dcusr, dcpw):
    return [
        f'$dcip\t\t= "{dcip}"\n',
        f'$rdd        = "{rdd}"\n',
        f'$rnb        = "{rnb}"\n',
        f'$dcusr      = "{dcusr}"\n',
        f'$dcpw       = "{dcpw}";$dcpass = ConvertTo-SecureString -AsPlainText $dcpw -Force;$domaincred = New-Object System.Management.Automation.PSCredential -ArgumentList $rnb\\$dcusr,$dcpass\n',
        f'Invoke-Command -ComputerName $dcip -Credential $domainCred -ScriptBlock {{\n'
    ]

def generar_bloque_usuario(numero):
    return (
        f' $Username="user{numero}"  ;$Password="Ch@ngeMeNow!";$Firstname="User"   '
        f';$Lastname="{numero}"    ;$EmailAddress="$Username@$using:rdd";$EmailAddress="$EmailAddress";'
        f'$OfficePhone="+123456789";New-ADUser -SamAccountName "$Username" -UserPrincipalName "$Username@$Using:rdd" '
        f'-Name "$Firstname $Lastname" -GivenName "$Firstname" -Surname "$Lastname" '
        f'-EmailAddress "$EmailAddress" -OfficePhone "$OfficePhone" -Enabled $True -ChangePasswordAtLogon $true '
        f'-DisplayName "$Firstname $Lastname" -AccountPassword (convertto-securestring $Password -AsPlainText -Force) '
        f'-PasswordNeverExpires $false'
    )

def main():
    input_file = "test_add_users_script.txt"
    output_file = "output_modified_script.ps1"

    # Solicitar los datos iniciales
    dcip = input("Introduce el valor para $dcip: ")
    rdd = input("Introduce el valor para $rdd: ")
    rnb = input("Introduce el valor para $rnb: ")
    dcusr = input("Introduce el valor para $dcusr: ")
    dcpw = input("Introduce el valor para $dcpw: ")

    inicio = int(input("Introduce el número de inicio: "))
    fin = int(input("Introduce el número de fin: "))

    # Generar encabezado y bloque de usuarios
    encabezado = generar_encabezado(dcip, rdd, rnb, dcusr, dcpw)
    usuarios = [generar_bloque_usuario(i) + "\n" for i in range(inicio, fin + 1)]

    # Cierre del bloque de PowerShell
    cierre = ["\n}\n"]

    # Escribir todo en un nuevo archivo
    with open(output_file, "w", encoding="utf-8") as f:
        f.writelines(encabezado + usuarios + cierre)

    print(f"\n✅ Script generado correctamente y guardado como: {output_file}")


if __name__ == "__main__":
    main()
