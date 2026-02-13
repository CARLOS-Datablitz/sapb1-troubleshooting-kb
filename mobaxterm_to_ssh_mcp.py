import re
import json
from pathlib import Path

ini_file = Path(r"C:\Users\c.pecho\OneDrive - iSystems GmbH\Dokumente\Casuistica\mobaxterm_sessions.ini")
output_file = Path(r"C:\Users\c.pecho\.ssh-mcp\config.json")

servers = {}
current_subrep = ""

with open(ini_file, 'r', encoding='utf-8', errors='ignore') as f:
    for line in f:
        line = line.strip()
        if line.startswith('SubRep='):
            current_subrep = line.split('=', 1)[1]
        elif '=#115#0%' in line:
            try:
                parts = line.split('=#115#0%')
                name = parts[0].strip()
                params = parts[1].split('%')
                if len(params) >= 3:
                    host, port, username = params[0], params[1] or '22', params[2] or 'root'
                    server_id = f"{host.replace('.', '_')}_{username}"
                    servers[server_id] = {"host": host, "port": int(port), "username": username, "privateKeyPath": "~/.ssh/id_rsa"}
            except: pass

output_file.parent.mkdir(parents=True, exist_ok=True)
config = {"allowedCommands": ["ls", "pwd", "cat", "grep", "df", "du", "tail", "systemctl", "cd"], "servers": servers}

with open(output_file, 'w') as f:
    json.dump(config, f, indent=2)

print(f"Guardado: {output_file}")
print(f"Servidores: {len(servers)}")
