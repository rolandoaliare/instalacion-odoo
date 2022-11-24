#!/usr/bin/env bash
# Para hacer ejecutable ejecutar chmod +x <nombre de este archivo

# Se debe tener el archivo de módulos en el directorio actual.

# Cambiar estas variables
ODOO_USER=odoo
ALIARE_PATH=/opt/$ODOO_USER/sources/aliare
ARCHIVO=modulos-aliare-20221122.tar.gz
ODOO_CONFIG=/etc/$ODOO_USER.conf
ODOO_BIN=/opt/$ODOO_USER/odoo/odoo-bin

if [ ! -f $ARCHIVO ]
then
  echo "No existe el archivo de módulos $ARCHIVO."
  exit
fi

sudo su - odoo -c "mkdir $ALIARE_PATH"
sudo cp $ARCHIVO $ALIARE_PATH 

sudo su - odoo -c "cd $ALIARE_PATH && tar xf $ARCHIVO"
sudo rm $ALIARE_PATH/$ARCHIVO



#Agregar modulos a addons_path
sudo sed -i "s:^addons_path.*:&,${ALIARE_PATH}:" $ODOO_CONFIG
sudo su - odoo -c "/usr/bin/env python3 $ODOO_BIN -c $ODOO_CONFIG --init web_responsive,pos_hide_cost_price_and_margin,pos_restrict,ks_pos_low_stock_alert,kg_hide_menu --stop-after-init"

