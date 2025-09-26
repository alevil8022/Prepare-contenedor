# ------
# Instalar Docker en Ubuntu
# ------
#
#

function mensaje
{
	echo "#--------------------------------------"
	echo $1
	echo "#--------------------------------------"
}

mensaje "CAMBIANDO NOMBRE DE LA VM"
hostnamectl set-hostname <nombredelamaquina>

#-------------------------------------------------------------

mensaje "Creando usuario Generico"
useradd -c "av1439" -m -d /home/av1439 -s /bin/bash av1439

echo "av1439  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

#-------------------------------------------------------------

mensaje "CAMBIANDO PASSWORD USUARIO"
# Generar el hash de la contraseña "MiPassword123"
HASH_PASSWORD=$(openssl passwd -6 'MiPassword123')

# Establecer la contraseña encriptada para el usuario 'miusuario'
echo "av1439:${HASH_PASSWORD}" | sudo chpasswd -e

#-------------------------------------------------------------
mensaje "Actualizando ultimos paquetes de SO.   "

apt update
apt dist-upgrade

#-------------------------------------------------------------

mensaje "INSTALANDO DOCKER "

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

mensaje "Instalando Docker, Docker-Compose.     "
# apt install docker docker.io docker-compose -y


# Add Docker's official GPG key:
apt-get update
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update

apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

apt-get update
apt-get install docker-compose-plugin



mensaje "Creando Usuario y grupo   "
groupadd docker
usermod -aG docker $USER

mensaje "Probando docker con Hello World"
docker run hello-world

#-------------------------------------------------------------
mensaje "Creando Directorios.     "
mkdir /container
mkdir -p /container/volume
mkdir -p /container/docker-compose

#-------------------------------------------------------------

mensaje "Agregando Alias en la configuracion"
echo "alias c='cd /container'" >> ~/.bashrc
echo "alias v='cd /container/volume'" >> ~/.bashrc
echo "alias d='cd /container/docker-compose'" >> ~/.bashrc

#-------------------------------------------------------------

mensaje "ACTUALIZANDO EL BANNER DE LA VM"
echo '#!/bin/bash'; while IFS= read -r line; do echo "echo '$line'"; done < banner/banner.txt > mymotd.sh
cp mymotd.sh /etc/profile.d/
chmod +x /etc/profile.d/mymotd.sh
systemctl restart sshd
#-------------------------------------------------------------

mensaje "INSTALANDO HTOP"

apt install htop

#-------------------------------------------------------------

mensaje "INSTALANDO TAILSCALE"

curl -fsSL https://tailscale.com/install.sh | sh

echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

sudo tailscale up

sudo tailscale set --advertise-exit-node

#-------------------------------------------------------------

mensaje "Modificando puertos SSH"
sudo echo "Port XXXX" >> /etc/ssh/sshd_config
sudo systemctl restart sshd

#-------------------------------------------------------------



#-------------------------------------------------------------

mensaje "Reiniciando"
systemctl reboot
