#!/bin/bash

# Asegurar que el usuario mysql tenga su home configurado (doble check)
usermod -d /var/lib/mysql mysql

# Iniciar servicios de sistema
service ssh start
service mysql start

# Limpiar posible dependencia corrupta y preparar logs
rm -rf /root/.m2/repository/org/glassfish/jaxb/jaxb-runtime/4.0.5
touch /home/redteam/ms-users.log /home/redteam/ms-accounts.log /home/redteam/ms-transactions.log /home/redteam/frontend.log
chown redteam:redteam /home/redteam/*.log

# Iniciar Backends en segundo plano
echo "Iniciando MS Users..."
cd /home/redteam/BicciWallet/Backend/ms-users && mvn spring-boot:run -DskipTests > /home/redteam/ms-users.log 2>&1 &

echo "Iniciando MS Accounts..."
cd /home/redteam/BicciWallet/Backend/ms-accounts && mvn spring-boot:run -DskipTests > /home/redteam/ms-accounts.log 2>&1 &

echo "Iniciando MS Transactions..."
cd /home/redteam/BicciWallet/Backend/ms-transactions && mvn spring-boot:run -DskipTests > /home/redteam/ms-transactions.log 2>&1 &

# Iniciar Frontend en segundo plano
echo "Iniciando Frontend Angular..."
cd /home/redteam/BicciWallet/Frontend && ng serve --host 0.0.0.0 --port 4200 > /home/redteam/frontend.log 2>&1 &

# Seguir los logs
tail -f /home/redteam/*.log
