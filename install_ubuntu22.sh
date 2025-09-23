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

mensaje "Creando usuario Generico"
useradd -c "usuario" -s /bin/bash av1439

echo "usuario  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers


mensaje "Actualizando ultimos paquetes de SO.   "

apt-get update

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

mensaje "Instalando Docker, Docker-Compose.     "
# apt install docker docker.io docker-compose -y


# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

sudo apt-get update
sudo apt-get install docker-compose-plugin


mensaje "Creando Directorios.     "
mkdir -p /container/volume
mkdir -p /container/docker-compose

mensaje "Creando Usuario y grupo   "
groupadd docker
usermod -aG docker $USER

mensaje "Agregando Alias en la configuracion"
echo "alias c='cd /container'" >> ~/.bashrc
echo "alias v='cd /container/volume'" >> ~/.bashrc
echo "alias d='cd /container/docker-compose'" >> ~/.bashrc


mensaje "ACTUALIZANDO EL BANNER DE LA VM"
echo '#!/bin/bash'; while IFS= read -r line; do echo "echo '$line'"; done < banner/banner.txt > mymotd.sh
cp mymotd.sh /etc/profile.d/
chmod +x /etc/profile.d/mymotd.sh
systemctl restart sshd

mensaje "CAMBIANDO NOMBRE DE LA VM"
hostnamectl set-hostname nuevonombre

mensaje "Reiniciando"
systemctl reboot
