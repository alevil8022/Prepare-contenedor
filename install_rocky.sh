# ------
# Instalar Docker en Rocky
# ------
#
#

function mensaje
{
	echo "#--------------------------------------"
	echo $1
	echo "#--------------------------------------"
}

#-----------------------------------
mensaje "CAMBIANDO EL NOMBRE DE LA MAQUINA"
hostnamectl set-hostname <NOMBRE_DE_LA_MAQUINA>
systemctl restart systemd-hostnamed

#-----------------------------------
mensaje "CREANDO USUARIO"
useradd -c "av1439" -m -d /home/av1439 -s /bin/bash av1439

#-----------------------------------
mensaje "AGREGAR USUARIO COMO SUDO"
echo "av1439  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

mensaje "CAMBIANDO PASSWORD USUARIO"
# Generar el hash de la contraseña "MiPassword123"
HASH_PASSWORD=$(openssl passwd -6 'MiPassword123')

# Establecer la contraseña encriptada para el usuario 'miusuario'
echo "av1439:${HASH_PASSWORD}" | sudo chpasswd -e




#-----------------------------------
mensaje "ACTUALIZANDO PAQUETES DE SO "

dnf update && dnf upgrade


#-----------------------------------
mensaje "INSTALANDO PODMAN"

dnf install podman -y
sudo dnf install epel-release -y
sudo dnf install python3 python3-pip -y
sudo pip3 install pyyaml python-dotenv
echo 'alias "podman compose"="podman-compose"' >> ~/.bashrc
source ~/.bashrc

#-----------------------------------
mensaje "DOCKER Y DOCKER COMPOSE OPCIONAL"

sudo dnf update -y
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo dnf install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker $USER

#-----------------------------------
mensaje "Probando docker con Hello World"
podman run hello-world


#-----------------------------------

mensaje "Creando Directorios.     "
mkdir /container
mkdir -p /container/volume
mkdir -p /container/docker-compose

#-----------------------------------
mensaje "Agregando Alias en la configuracion"
echo "alias c='cd /container'" >> ~/.bashrc
echo "alias v='cd /container/volume'" >> ~/.bashrc
echo "alias d='cd /container/docker-compose'" >> ~/.bashrc

mensaje "ACTUALIZANDO EL BANNER DE LA VM"
echo '#!/bin/bash'; while IFS= read -r line; do echo "echo '$line'"; done < banner/banner2.txt > /etc/motd.d/99-custom
sudo chmod +x /etc/motd.d/99-custom
systemctl restart sshd



mensaje "Reiniciando"
systemctl reboot
