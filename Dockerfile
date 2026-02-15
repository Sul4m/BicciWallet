FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# 1. Instalar herramientas básicas, MySQL, Maven, Node.js y Angular
RUN apt-get update && apt-get install -y \
    curl git wget unzip nano vim net-tools openssh-server \
    openjdk-17-jdk \
    python3 python3-pip \
    iputils-ping gnupg2 ca-certificates gnupg lsb-release \
    software-properties-common maven mysql-server

# 2. Eliminar Node.js preinstalado y agregar Node.js 20 + Angular CLI 17
RUN apt-get remove -y nodejs npm libnode* && \
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g @angular/cli@17

# 3. Crear usuario y habilitar SSH
RUN useradd -m redteam && echo "redteam:redteam" | chpasswd && \
    mkdir /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# 4. Clonar el repositorio BicciWallet
WORKDIR /home/redteam
RUN git clone https://github.com/GuzmanAndrew/BicciWallet.git

# 5. Instalar dependencias del frontend Angular
WORKDIR /home/redteam/BicciWallet/Frontend
RUN npm install

# 6. Configurar MySQL: crear DB y usuario
RUN usermod -d /var/lib/mysql mysql && service mysql start && \
    mysql -e "CREATE DATABASE wallet_db;" && \
    mysql -e "CREATE USER 'admin'@'localhost' IDENTIFIED BY 'admin123';" && \
    mysql -e "GRANT ALL PRIVILEGES ON wallet_db.* TO 'admin'@'localhost';" && \
    mysql -e "FLUSH PRIVILEGES;"

# 7. Exponer puertos
# Note: Host should map 3307 -> 3306
EXPOSE 8081 8082 8083 4200 22 3306  

# 8. Ejecutar todos los servicios
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
