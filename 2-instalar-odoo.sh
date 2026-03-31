#!/bin/sh

echo INSTALANDO DEPENDENCIAS CON APT
echo -----------------------
sudo apt update
sudo apt upgrade -y
sudo apt install -y python3 python3-pip
sudo apt install -y python3-dev libxml2-dev libxslt1-dev libldap2-dev libsasl2-dev \
    libtiff5-dev libjpeg8-dev libopenjp2-7-dev zlib1g-dev libfreetype6-dev \
    liblcms2-dev libwebp-dev libharfbuzz-dev libfribidi-dev libxcb1-dev libpq-dev

#echo INSTALLING NPM
#echo -----------------------
#sudo apt-get install -y npm
#sudo npm install -g rtlcss
#sudo npm install -g less less-plugin-clean-css
#sudo apt-get install -y node-less

echo INSTALLANDO WKHTML2PDF
echo -----------------------
wget https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.focal_amd64.deb
sudo apt -y install ./wkhtmltox_0.12.5-1.focal_amd64.deb

odoo_user=odoo
echo CREANDO USUARIO $odoo_user
echo -----------------------
sudo adduser --system --quiet --shell=/bin/bash --home=/opt/$odoo_user --group ${odoo_user}
ls /opt/$odoo_user
echo
echo INSTALANDO POSTGRESQL
echo -----------------------
sudo apt install -y postgresql postgresql-server-dev-all
echo CREANDO DATABASE USER $odoo_user.
echo -----------------------
echo 
sudo su - postgres -c "createuser --no-superuser --createdb --login $odoo_user" 2> /dev/null || true
echo
echo ODOO
echo -----------------------
cd /opt/$odoo_user
sudo git clone https://github.com/odoo/odoo.git --depth 1 --branch 15.0 --single-branch 
sudo chown -R $odoo_user:$odoo_user /opt/$odoo_user
sudo su - odoo -c "cd /opt/$odoo_user/odoo && pip3 install -r requirements.txt"
echo
echo POST-INSTALLATION
echo -----------------------
sudo mkdir -p /var/log/$odoo_user
sudo chown $odoo_user:root /var/log/$odoo_user
read -p "Nombre DB[$odoo_user]:" DB_NAME
DB_NAME=${DB_NAME:-$odoo_user}
echo "La base de datos será $DB_NAME"
CONFIG_FILE=/etc/$odoo_user.conf
if [ -f "$CONFIG_FILE" ]; then
	sudo rm -f $CONFIG_FILE
fi
sudo tee -a $CONFIG_FILE <<EOF > /dev/null
[options]
; This is the password that allows database operations:
; admin_passwd = admin
db_host = False
db_port = False
db_user = False
db_password = False
addons_path = /opt/$odoo_user/odoo/addons
logfile = /var/log/$odoo_user/odoo.log
unaccent = True
db_name = $DB_NAME
dbfilter = $DB_NAME
server_wide_modules = base,web
http_interface = 127.0.0.1
proxy_mode = True
EOF

sudo chown $odoo_user: /etc/$odoo_user.conf
sudo chmod 640 /etc/$odoo_user.conf

echo ODOO SERVICE
echo -----------------------
SERVICE_FILE=/etc/systemd/system/$odoo_user.service
if [ -f "$SERVICE_FILE" ]; then
	sudo rm -f $SERVICE_FILE
fi
sudo tee -a $SERVICE_FILE <<EOF > /dev/null 
[Unit]
  Description=Odoo ERP - Aliare SRL
  Documentation=http://www.odoo.com
  Requires=postgresql.service
  After=network.target postgresql.service
[Service]
  SyslogIdentifier=odoo15
  PermissionStartOnly=true
  User=$odoo_user
  Group=$odoo_user
  StandarOuput=journal+console
  Restart=always
  RestartSec=3
  Type=exec
  User=$odoo_user
  ExecStart=/usr/bin/env python3 /opt/$odoo_user/odoo/odoo-bin -c $CONFIG_FILE
[Install]
  WantedBy=default.target
EOF

sudo chmod 0644 $SERVICE_FILE

sudo mkdir -p /var/opt/$odoo_user/data_dir
sudo chown -R $odoo_user:$odoo_user /var/opt/$odoo_user/data_dir

sudo su - odoo -c "/usr/bin/env python3 /opt/$odoo_user/odoo/odoo-bin -c $CONFIG_FILE --language es_AR --load-language es_AR --init base,web,point_of_sale --data-dir /var/opt/$odoo_user/data_dir --without-demo all --save --db-template template1 --no-database-list --stop-after-init"


sudo systemctl enable odoo.service # Habilita el servicio para iniciarse con el SO
echo "Para iniciar el servicio use: 'sudo systemctl start $odoo_user.service'"

