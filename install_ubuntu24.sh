#!/bin/bash

# --- CONFIGURACIÓN ---
NUEVO_HOSTNAME="servidor-docker-pro"
USUARIO="av1439"
PASS_PLANO="MiPassword123"
PUERTO_SSH="4422"
# ---------------------

# Colores para los mensajes
VERDE='\033[0;32m'
AZUL='\033[0;34m'
NC='\033[0m' # Sin color

# Parar si hay errores
set -e

function mensaje {
    echo -e "${AZUL}#--------------------------------------${NC}"
    echo -e "${AZUL}# $1${NC}"
    echo -e "${AZUL}#--------------------------------------${NC}"
}

function conf_general {
    mensaje "CONFIGURACIÓN GENERAL DEL SISTEMA"
    hostnamectl set-hostname "$NUEVO_HOSTNAME"
    
    # Actualización de paquetes
    apt update && apt dist-upgrade -y
    apt install -y htop zsh curl git gnupg ca-certificates
    
    # Configurar ZSH como shell por defecto para el sistema y futuros usuarios
    chsh -s $(which zsh) root
    sed -i 's|SHELL=/bin/bash|SHELL=/bin/zsh|' /etc/default/useradd
}

function conf_usuario {
    mensaje "CREACIÓN DE USUARIO Y ENTORNO ZSH"
    if ! id "$USUARIO" &>/dev/null; then
        useradd -m -s /bin/zsh "$USUARIO"
        echo "$USUARIO  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
        HASH_PASSWORD=$(openssl passwd -6 "$PASS_PLANO")
        echo "$USUARIO:${HASH_PASSWORD}" | chpasswd -e
    fi

    # Instalación de Oh My Zsh (No interactiva)
    if [ ! -d "/home/$USUARIO/.oh-my-zsh" ]; then
        sudo -u "$USUARIO" sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Aliases
    for rc in "/home/$USUARIO/.zshrc" "/root/.zshrc"; do
        [ -f "$rc" ] || touch "$rc"
        echo -e "\nalias c='cd /container'\nalias v='cd /container/volume'\nalias d='cd /container/docker-compose'" >> "$rc"
    done
}

function conf_firewall {
    mensaje "CONFIGURACIÓN DEL FIREWALL (UFW)"
    apt install -y ufw
    ufw default deny incoming
    ufw default allow outgoing
    
    # Permitir el puerto SSH personalizado
    ufw allow "$PUERTO_SSH"/tcp
    # Permitir tráfico de la interfaz de Tailscale
    ufw allow in on tailscale0
    
    # Cambiar puerto en SSHD
    sed -i "s/#Port 22/Port $PUERTO_SSH/" /etc/ssh/sshd_config
    if ! grep -q "Port $PUERTO_SSH" /etc/ssh/sshd_config; then
        echo "Port $PUERTO_SSH" >> /etc/ssh/sshd_config
    fi
    
    ufw --force enable
}

function conf_docker {
    mensaje "INSTALACIÓN Y CONFIGURACIÓN DE DOCKER"
    # Limpieza de versiones viejas
    for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do 
        apt-get remove -y $pkg || true
    done

    # Repositorio oficial
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    # Permisos y directorios
    usermod -aG docker "$USUARIO"
    mkdir -p /container/volume /container/docker-compose
    chown -R "$USUARIO":"$USUARIO" /container
}

function conf_tailscale {
    mensaje "CONFIGURACIÓN DE TAILSCALE"
    curl -fsSL https://tailscale.com/install.sh | sh
    
    # Habilitar IP Forwarding para Exit Node
    echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
    echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
    sysctl -p /etc/sysctl.d/99-tailscale.conf
    
    echo "Tailscale instalado. Recuerda ejecutar 'sudo tailscale up' manualmente para loguearte."
}

function conf_banner {
    mensaje "CONFIGURACIÓN DEL BANNER (MOTD)"
    if [ -f "banner/banner.txt" ]; then
        echo '#!/bin/bash' > /etc/profile.d/mymotd.sh
        while IFS= read -r line; do 
            echo "echo '$line'" >> /etc/profile.d/mymotd.sh
        done < banner/banner.txt
        chmod +x /etc/profile.d/mymotd.sh
    else
        echo "Banner no encontrado en banner/banner.txt, saltando paso."
    fi
}

function finalizacion {
    echo -e "\n${VERDE}====================================================${NC}"
    echo -e "${VERDE}   ¡SCRIPT COMPLETADO CON ÉXITO!${NC}"
    echo -e "${VERDE}====================================================${NC}"
    echo -e "Detalles de la configuración:"
    echo -e "- Usuario: $USUARIO"
    echo -e "- Puerto SSH: $PUERTO_SSH (Recuerda usar: ssh -p $PUERTO_SSH $USUARIO@ip)"
    echo -e "- Firewall: ACTIVO (UFW)"
    echo -e "- Shell: ZSH (Default)"
    echo -e "- Docker: Instalado y listo"
    echo -e "${AZUL}Reiniciando sistema en 10 segundos...${NC}\n"
    sleep 10
    reboot
}

# --- EJECUCIÓN DEL SCRIPT ---
conf_general
conf_usuario
conf_firewall
conf_docker
conf_tailscale
conf_banner
finalizacion
