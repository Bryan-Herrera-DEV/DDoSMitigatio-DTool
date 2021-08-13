# Mitigacion DDoS 

## Archivos
**DTool** Este script instala de forma automática y segura todas las reglas de iptables y modificaciones del kernel que se encuentran en este repositorio al instante. 
[Descargar v1.0](https://github.com/Bryan-Herrera-DEV/DDoSMitigatio-DTool/blob/main/tool/DTool.sh)

## Descargo de responsabilidad
Algunas reglas pueden interferir con el funcionamiento de las herramientas y sugerencias de este repositorio. Asegúrese de tener un método de emergencia para deshabilitar el Firewall o revertir los cambios realizados con este repositorio en caso de que pierda el acceso al servidor.

## Index
- [Kernel](#Modificaciones-de-Kernel)
  - [Retirar solicitudes ICMP ECHO](#Retirar-solicitudes-ICMP-ECHO)
  - [No aceptar la redirección ICMP](#No-aceptar-la-redirección-ICMP)
  - [Descartar paquetes enrutados de origen](#Descartar-paquetes-enrutados-de-origen)
  - [Habilitar SYN-Cookie (para evitar SYN Flood)](#Habilitar-SYN-Cookie-para-evitar-SYN-Flood)
  - [Aumentar la acumulación de TCP SYN (para evitar la inanición de TCP)](#Incrementar-TCP-SYN-backlog)
  - [Decrementar los intentos TCP SYN-ACK(para evitar la inanición de TCP)](#Decrementar-los-intentos-TCP-SYN-ACK)
  - [Habilitar proteccion IP Spoofing](#Habilitar-proteccion-IP-Spoofing)
  - [Desabilitar paquetes de trazado SYN](#Desabilitar-paquetes-de-trazado-SYN)

- [IPTables](#IPTables)
  - [Eliminar paquetes no válidos](#Eliminar-paquetes-no-válidos)
  - [Bloquear paquetes con flags TCP falsas](#Bloquear-paquetes-con-flags-TCP-falsas)
  - [Eliminar ICMP](#Eliminar-ICMP)
  - [Soltar fragmentos en todas las cadenass](#Soltar-fragmentos-en-todas-las-cadenas)
  - [Limite de conexiones por IP](#Limite-de-conexiones-por-IP)
  - [Limite de paquetes RST ](#Limite-de-paquetes-RST)
  - [Usar SYN-PROXY](#Usar-SYN-PROXY)
  - [Prevenir fuerza bruta de SSH](#Prevenir-fuerza-bruta-de-SSH)
  - [Prevenir Escaneo de Puertos](#Prevenir-Escaneo-de-Puertos)
 
  
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

#### Descartar paquetes enrutados de origen
```shell
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route
```

#### Habilitar SYN-Cookie para evitar SYN Flood
Para prevenir SYN Flood y la iniciacion TCP .
```shell
sysctl -w net/ipv4/tcp_syncookies=1
sysctl -w net/ipv4/tcp_timestamps=1
```

#### Incrementar TCP SYN backlog
Para prevenir la iniciacion de TCP.
```shell
echo 2048 > /proc/sys/net/ipv4/tcp_max_syn_backlog
```
#### Decrementar los intentos TCP SYN-ACK
Para prevenir la iniciacion de TCP.
```shell
echo 3 > /proc/sys/net/ipv4/tcp_synack_retries
```

#### Habilitar proteccion IP Spoofing 
Para prevenir IP Spoof.
```shell
echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
```

#### Desabilitar paquetes de trazado SYN
Para evitar que el sistema utilice recursos para rastrear paquetes SYN.
```shell
sysctl -w net/netfilter/nf_conntrack_tcp_loose=0
```

## IPTables
#### Eliminar paquetes no válidos
```shell
iptables -A INPUT -m state --state INVALID -j DROP
```

#### Bloquear paquetes con flags TCP falsas
```shell
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
```

#### Eliminar ICMP
Para prevenir ataques pequeños
```shell
iptables -t mangle -A PREROUTING -p icmp -j DROP
```

#### Soltar fragmentos en todas las cadenas
```shell
iptables -t mangle -A PREROUTING -f -j DROP
```

#### Limite de conexiones por IP
```shell
iptables -A INPUT -p tcp -m connlimit --connlimit-above 111 -j REJECT --reject-with tcp-reset
```

#### Limite de paquetes RST 
```shell
iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP
```

#### Usar SYN-PROXY
```shell
iptables -t raw -A PREROUTING -p tcp -m tcp --syn -j CT --notrack
iptables -A INPUT -p tcp -m tcp -m conntrack --ctstate INVALID,UNTRACKED -j SYNPROXY --sack-perm --timestamp --wscale 7 --mss 1460
iptables -A INPUT -m state --state INVALID -j DROP
```

#### Prevenir fuerza bruta de SSH
```shell
iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set
iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP
```

#### Prevenir Escaneo de Puertos
```shell
iptables -N port-scanning
iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
iptables -A port-scanning -j DROP
```

## Recursos
- [hackplayers.com](https://www.hackplayers.com/2016/04/proteccion-ddos-mediante-iptables.html)
- [stackexchange.com](https://security.stackexchange.com/questions/4603/tips-for-a-secure-iptables-config-to-defend-from-attacks-client-side)

### Made with ♡ by Bryan Herrera
