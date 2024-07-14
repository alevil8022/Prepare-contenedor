# ------
# Instalar Docker
# ------
echo "#--------------------------------------"
echo "Actualizando ultimos paquetes de SO.   "
echo "#--------------------------------------"
apt-get update

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

echo "#--------------------------------------"
echo "Instalando Docker, Docker-Compose.     "
echo "#--------------------------------------"
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


echo "#--------------------------------------"
echo "Creando Directorios.     "
echo "#--------------------------------------"
mkdir /contenedores
cd /contenedores
mkdir volume
mkdir docker-compose


