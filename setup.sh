#!/bin/bash

# --- Instalando Docker ---
sudo apt update && sudo apt upgrade -y
sudo apt install curl htop ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF

sudo apt update && sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

# --- Criando ambiente do HomeServer ---
mkdir -p env

# VARIAVEIS GLOBAIS
TZ=America/Sao_Paulo

# .ENV DE PORTAS DE SERVIÇOS
cat > .env << EOF
HOMARR_PORT=7575
PORTAINER_PORT=9000
UPTIME-KUMA_PORT=3001
NGINX_PROXY_MANAGER_PORT1=80
NGINX_PROXY_MANAGER_PORT2=81
NGINX_PROXY_MANAGER_PORT3=443
FILEBROWSER_PORT=1200
EOF

# .ENV DO HOMARR
HOMARR_SECRET_KEY=$(openssl rand -hex 32)
cat > env/.env.homarr << EOF
HOMARR_SECRET_KEY=$HOMARR_SECRET_KEY
TZ=$TZ
EOF

# .ENV DO PORTAINER
cat > env/env.portainer << EOF
TZ=$TZ
EOF

# .ENV DO UPTIME-KUMA
cat > env/env.uptime-kuma << EOF
TZ=$TZ
EOF

# .ENV DO NGINX PROXY MANAGER
cat > env/env.nginx-proxy-manager << EOF
TZ=$TZ
EOF

# .ENV DO FILEBROWSER
cat > env/env.filebrowser << EOF
TZ=$TZ
PUID=1000
PGID=1000
EOF

# ADICIONANDO O USUARIO AO GRUPO DOCKER PARA EVITAR O USO DE SUDO
sudo usermod -aG docker $USER

# CRIANDO PASTAS DO SERVIDOR
mkdir -p homeserver
mkdir -p homeserver/export
mkdir -p homeserver/data
mkdir -p homeserver/media
mkdir -p homeserver/backups

# COPIANDO CONTEUDO PRINCIPAL DO SERVIDOR PARA A PASTA DO SERVIDOR
mv docker-compose.yml homeserver/
mv env/ homeserver/
mv .env homeserver/
