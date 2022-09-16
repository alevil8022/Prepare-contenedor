# ------
# Instalar Docker
# ------
echo "#--------------------------------------"
echo "Actualizando ultimos paquetes de SO.   "
echo "#--------------------------------------"
apt-get update

echo "#--------------------------------------"
echo "Instalando Docker, Docker-Compose.     "
echo "#--------------------------------------"
apt install docker docker.io docker-compose -y

echo "#--------------------------------------"
echo "Creando Directorios.     "
echo "#--------------------------------------"
mkdir /contenedores
cd /contenedores
mkdir volume
mkdir docker-compose


