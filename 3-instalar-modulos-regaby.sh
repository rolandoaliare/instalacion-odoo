#!/usr/bin/env bash
# Para hacer ejecutable ejecutar chmod +x 3-instalar-modulos-regaby.sh

# Cambiar estas variables
ODOO_USER=odoo
CUSTOM_PATH=/opt/odoo/sources
ODOO_CONFIG=/etc/odoo.conf
ODOO_BIN=/opt/$ODOO_USER/odoo/odoo-bin

sudo su - $ODOO_USER -c "mkdir -p $CUSTOM_PATH"
#clonar regaby/odoo-custom branch 15.0-adhoc
sudo su - $ODOO_USER -c "git clone https://github.com/regaby/odoo-custom.git --branch 15.0-adhoc --single-branch --depth 1 $CUSTOM_PATH/odoo-custom"
#clonar hormigaG/odoo-argentina-ce.git -b 15.0_refact
sudo su - $ODOO_USER -c "git clone https://github.com/hormigaG/odoo-argentina-ce.git --branch 15.0_refact --single-branch --depth 1 $CUSTOM_PATH/odoo-argentina-ce"
sudo apt -y install swig libssl-dev
sudo su - $ODOO_USER <<EOT
cd $CUSTOM_PATH/odoo-argentina-ce
pip3 install -r requirements.txt 
cd -
exit
EOT

#clonar OCA/reporting-engine.git
sudo su - $ODOO_USER -c "git clone https://github.com/OCA/reporting-engine.git --branch 15.0 --single-branch --depth 1 $CUSTOM_PATH/reporting-engine"
#clonar OCA/stock-logistics-warehouse.git
sudo su - $ODOO_USER -c "git clone https://github.com/OCA/stock-logistics-warehouse.git --branch 15.0 --single-branch --depth 1 $CUSTOM_PATH/stock-logistics-warehouse"
#clonar odoo/design-themes.git
sudo su - $ODOO_USER -c "git clone https://github.com/odoo/design-themes.git --branch 15.0 --single-branch --depth 1 $CUSTOM_PATH/design-themes"

#Agregar modulos a addons_path
#<carpetademodulos>/odoo-argentina-ce,<carpetademodulos>/odoo-custom,<carpetademodulos>/aliare
sudo sed -i "s:^addons_path.*:&,${CUSTOM_PATH}/,${CUSTOM_PATH}/odoo-custom,${CUSTOM_PATH}/odoo-argentina-ce:" $ODOO_CONFIG
sudo su - $ODOO_USER -c "/usr/bin/env python3 $ODOO_BIN -c $ODOO_CONFIG --init l10n_ar_afipws_fe,l10n_ar_pos_einvoice_ticket --stop-after-init"

