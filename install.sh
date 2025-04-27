# ------
# Instalar Docker
# ------
#
#

function mensaje
{
	echo "#--------------------------------------"
	echo $1
	echo "#--------------------------------------"
}


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
mkdir /contenedores
cd /contenedores
mkdir volume
mkdir docker-compose


mensaje "Creando Usuario y grupo   "
groupadd docker
usermod -aG docker $USER

mensaje "Agregando Alias en la configuracion"
echo "alias c='cd /contenedores'" >> ~/.bashrc
echo "alias v='cd /contenedores/volume'" >> ~/.bashrc
echo "alias d='cd /contenedores/docker-compose'" >> ~/.bashrc


mensaje "Reiniciando"
systemctl reboot
