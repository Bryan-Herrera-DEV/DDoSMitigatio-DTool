# DDoS Mitigacion

## Archivos
**DTool** Este script instala de forma automática y segura todas las reglas de iptables y modificaciones del kernel que se encuentran en este repositorio al instante. 
[Descargar v1.0](https://github.com/Bryan-Herrera-DEV/DDoSMitigatio-DTool/blob/main/tool/DTool.sh)

## Descargo de responsabilidad
Algunas reglas pueden interferir con el funcionamiento de las herramientas y sugerencias de este repositorio. Asegúrese de tener un método de emergencia para deshabilitar el Firewall o revertir los cambios realizados con este repositorio en caso de que pierda el acceso al servidor.

## Index
- [Kernel](#Modificaciones-de-Kernel)
  - [Retirar solicitudes ICMP ECHO](#Retirar-solicitudes-ICMP-ECHO)
  - [No aceptar la redirección ICMP](#No-aceptar-la-redirección-ICMP)
  
## Modificaciones de Kernel
#### Retirar solicitudes ICMP ECHO
Para prevenir ataques pequeños.
```shell
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
```

#### No aceptar la redirección ICMP
Para prevenir ataques pequeños.
```shell
echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
```
