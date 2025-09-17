# ------
# Instalar Docker en Debian 12
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
useradd -c "av1439" -m -d /home/av1439 -s /bin/bash av1439

echo "av1439  ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

mensaje "Actualizando ultimos paquetes de SO.   "

apt-get update

for pkg in docker.io docker-doc docker-compose podman-docker containerd runc; do sudo apt remove $pkg; done

# Add Docker's official GPG key:
apt update 
apt install ca-certificates curl 
install -m 0755 -d /etc/apt/keyrings 
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc 
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \ 
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \ 
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \ 
    tee /etc/apt/sources.list.d/docker.list > /dev/null 
apt update

apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

mensaje "Probando docker con Hello World"
docker run hello-world

mensaje "Subiendo Servicio Docker"
systemctl status docker

systemctl start docker 
docker run hello-world

systemctl disable docker 
systemctl enable docker


mensaje "Creando Directorios.     "
mkdir /container
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
cp banner/banner.txt /etc/
echo "Banner /etc/Banner.txt" >> /etc/ssh/sshd_config

mensaje "CAMBIANDO NOMBRE DE LA VM"
hostnamectl set-hostname io-cocuy-vpn


mensaje "Reiniciando"
systemctl reboot
