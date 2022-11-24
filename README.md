Estos script de instalación deberán ejecutarse en órden.

Dentro de cada script existen variable que pueden personalizarse, deberían tener valores coherentes en los distintos scripts.

El script 1, configura ubuntu en es_AR y timezone America/Argentina/Buenos_Aires
Debe reinciar el servidor para que impacten los cambios.

El script 2, actualiza ubuntu e instala las dependencias necesarias para odoo.
Aparte crea el usuario de odoo en el sistema operativo, este usuario será utilizado para ejecutar el servicio y para la instalación de dependencias con pip.
También habilita odoo como servicio pero no lo inicia debido a que hay que ejecutar los demás scripts.
Este script también instala postgresql y configura el usuario utilizado para la conexión de odoo.
Finalmente, este script pide el nombre para la base de datos que será utilizada.

El script 3, instala y habilita los módulos de regaby.

Finalmente el script 4, instala los módulo utilizados por aliare. Este script necesita el archivo de módulos comprimidos y los instalar en la carpeta de módulos de aliare.

NOTA: Para quitar la versión de docker, se debería bajar los contenedores de docker, según el video el comando sería con los comandos
  $ sd rmall 
  $ oe -R y oe -

El servicio de odoo se puede detener e iniciar utilizando el comando systemctl:
  $ sudo systemctl start odoo.service
