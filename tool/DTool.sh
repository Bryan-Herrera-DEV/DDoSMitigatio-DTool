# Modules
ignore_ICMP () {
    echo "Instalando proteccion ICMP"
    echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts
    echo "** Kernel: Configurando parametro: icmp_echo_ignore_broadcast -> true"
    echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects
    echo "** Kernel: Configurando parametro: accept_redirects -> false"
    iptables -t mangle -A PREROUTING -p icmp -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING -p icmp -> DROP"
}

drop_routed_packets () {
    echo "Instalando paquetes enrutados de origen"
    echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route
    echo "** Kernel: Configurando parametro: accept_source_route -> false"
}

tcp_syn_cookies () {
    echo "Instalando TCP Syn cookies"
    sysctl -w net/ipv4/tcp_syncookies=1
    echo "** Kernel: Configurando parametro: tcp_syncookies -> true"
}

tcp_syn_backlog () {
    echo "Incrementando TCP Syn Backlog"
    echo 2048 > /proc/sys/net/ipv4/tcp_max_syn_backlog
    echo "** Kernel: Configurando parametro: tcp_max_syn_backlog -> 2048"
}

tcp_syn_ack () {
    echo "Decrementando intentos TCP Syn-Ack"
    echo 3 > /proc/sys/net/ipv4/tcp_synack_retries
    echo "** Kernel: Configurando parametro: tcp_synack_retries -> 3"
}

ip_spoof () {
    echo "Habilitando proteccion IP Spoof"
    echo 1 > /proc/sys/net/ipv4/conf/all/rp_filter
    echo "** Kernel: Configurando parametro: rp_filter -> true"
}

disable_syn_packet_track () {
    echo "Desabilitando paquete SYN Track"
    sysctl -w net/netfilter/nf_conntrack_tcp_loose=0
    echo "** Kernel: Configurando parametro: nf_conntrack_tcp_loose -> false"
}

drop_invalid_packets () {
    echo "Instalando invalidacion de packet drop"
    iptables -A INPUT -m state --state INVALID -j DROP
    echo "** IPTables: Configurando regla: -A INPUT -m state INVALID -j DROP"
}

bogus_tcp_flags () {
    echo "Instalando indicadores TCP falsos"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING --tcp-flags FIN,SYN,RST,PSH,ACK,URG NONE -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,SYN FIN,SYN -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING --tcp-flags FIN,SYN FIN,SYN -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,RST SYN,RST -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING --tcp-flags SYN,RST SYN,RST -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING --tcp-flags SYN,FIN SYN,FIN -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,RST FIN,RST -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING --tcp-flags  FIN,RST FIN,RST -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags FIN,ACK FIN -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING --tcp-flags FIN,ACK FIN -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,URG URG -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING --tcp-flags ACK,URG URG -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,FIN FIN -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING --tcp-flags ACK,FIN FIN -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ACK,PSH PSH -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING --tcp-flags ACK,PSH PSH -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL ALL -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING --tcp-flags ALL ALL -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL NONE -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING --tcp-flags ALL NONE -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL FIN,PSH,URG -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING --tcp-flags ALL FIN,PSH,URG -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,FIN,PSH,URG -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING --tcp-flags ALL SYN,FIN,PSH,URG -> DROP"
    iptables -t mangle -A PREROUTING -p tcp --tcp-flags ALL SYN,RST,ACK,FIN,URG -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING --tcp-flags ALL SYN,RST,ACK,FIN,URG -> DROP"
}

drop_fragment_chains () {
    echo "Soltando fragmentos en todas las cadenas"
    iptables -t mangle -A PREROUTING -f -j DROP
    echo "** IPTables: Configurando regla: -t mangle -A PREROUTING -f -> DROP"
}

tcp_syn_timestamps () {
    echo "Configurando TCP Syn Timestamps"
    sysctl -w net/ipv4/tcp_timestamps=1
    echo "** Kernel: Setting parameter: tcp_timestamps -> true"
}

limit_cons_per_ip () {
    echo "Configurando conexion maxima por IP"
    iptables -A INPUT -p tcp -m connlimit --connlimit-above 111 -j REJECT --reject-with tcp-reset
    echo "** IPTables: Configurando regla: TCP -m connlimit --connlimit-above 111 -> REJECT WITH TCP RESET"
}

limit_rst_packets () {
    echo "Configurando limite de paquetes RST "
    iptables -A INPUT -p tcp --tcp-flags RST RST -m limit --limit 2/s --limit-burst 2 -j ACCEPT
    echo "** IPTables: Configurando regla: -A INPUT -p tcp --tcp-flags RST RST -m limit --limit2/s -> ACCEPT"
    iptables -A INPUT -p tcp --tcp-flags RST RST -j DROP
    echo "** IPTables: Configurando regla: -A INPUT -p tcp --tcp-flags RST RST -> DROP"
}

syn_proxy () {
    echo "Instalando SYN Proxy"
    iptables -t raw -A PREROUTING -p tcp -m tcp --syn -j CT --notrack
    echo "** IPTables: Configurando regla: raw -A PREROUTING -p tcp -m tcp --syn --notrack -> CT"
    iptables -A INPUT -p tcp -m tcp -m conntrack --ctstate INVALID,UNTRACKED -j SYNPROXY --sack-perm --timestamp --wscale 7 --mss 1460
    echo "** IPTables: Configurando regla: TCP -m conntrack --ctstate INVALID,UNTRACKET -j SYNPROXY 1460"
    iptables -A INPUT -m state --state INVALID -j DROP
    echo "** IPTables: Configurando regla: -A INPUT -m state INVALID -j DROP"
}

prevent_ssh_bf () {
    echo "Instalando deteccion SSH"
    iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --set
    echo "** IPTables: Configurando regla: SSH -m conntrack --ctstate NEW -m recent --set"
    iptables -A INPUT -p tcp --dport ssh -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -j DROP
    echo "** IPTables: Configurando regla: SSH --ctstate NEW -m recent --update --seconds 60 --hitcount 10 -> DROP"
}

prevent_port_scanner () {
    echo "Instalando deteccion de Port Scanning"
    iptables -N port-scanning
    echo "** IPTables: Configurando regla: -N port-scanning"
    iptables -A port-scanning -p tcp --tcp-flags SYN,ACK,FIN,RST RST -m limit --limit 1/s --limit-burst 2 -j RETURN
    echo "** IPTables: Configurando regla: TCP SYN,ACK,FIN,RST RST -m limit 1/s --limit-burst 2 -> RETURN"
    iptables -A port-scanning -j DROP
    echo "** IPTables: Configurando regla: -A portscanning -> DROP"
}

# Utilities
install_all () {
    ignore_ICMP
    drop_routed_packets
    tcp_syn_cookies
    tcp_syn_backlog
    tcp_syn_ack
    ip_spoof
    disable_syn_packet_track
    drop_invalid_packets
    bogus_tcp_flags
    drop_fragment_chains
    limit_cons_per_ip
    syn_proxy
    prevent_ssh_bf
    prevent_port_scanner
    limit_rst_packets
    tcp_syn_timestamps
}

# MOTD
echo "
 ____    ______                ___      
/\  _`\ /\__  _\              /\_ \     
\ \ \/\ \/_/\ \/   ___     ___\//\ \    
 \ \ \ \ \ \ \ \  / __`\  / __`\\ \ \   
  \ \ \_\ \ \ \ \/\ \L\ \/\ \L\ \\_\ \_ 
   \ \____/  \ \_\ \____/\ \____//\____\
    \/___/    \/_/\/___/  \/___/ \/____/

    ❄ DTool v1.0 by CR1P70 HUN73R"

echo "
    ╔═════════════════════════════════════════════╗
    ║                                             ║
    ║  1.  Ignorar paquetes ICMP                  ║
    ║  2.  Descartar paquetes enrutados de origen ║
    ║  3.  Habilitar cookies de sincronización de ║
    ║       TCP                                   ║
    ║  4.  Habilitar TCP Timestamps               ║
    ║  5.  Incrementar TCP SYN Backlog            ║
    ║  6.  Decrementar reintentos TCP SYN-ACK     ║
    ║  7.  Habilitar proteccion IP Spoof          ║
    ║  8.  Desabilitar SYN Packet track           ║
    ║  9.  Eliminar paquetes inválidos            ║
    ║  10. Insertar falsos TCP Flags FIN,SYN,     ║
    ║        RST,ACK                              ║
    ║  11. Soltar fragmentos en todas las cadenas ║
    ║  12. Limitar conexiones IP                  ║
    ║  13. Limitar RST Packets                    ║
    ║  14. Usar SYN-PROXY                         ║
    ║  15. Prevenir Bruteforce SSH                ║
    ║  16. Prevenir escaneo de puertos            ║
    ║                                             ║
    ║  99.  Instalar todos los scripts            ║
    ║                                             ║
    ╚═════════════════════════════════════════════╝
"

read -p " Selecciona una opcion: " option

case $option in
    1) ignore_ICMP;;
    2) drop_routed_packets;;
    3) tcp_syn_cookies;;
    4) tcp_syn_timestamps;;
    5) tcp_syn_backlog;;
    6) tcp_syn_ack;;
    7) ip_spoof;;
    8) disable_syn_packet_track;;
    9) drop_invalid_packets;;
    10) bogus_tcp_flags;;
    11) drop_fragment_chains;;
    12) limit_cons_per_ip;;
    13) limit_rst_packets;;
    14) syn_proxy;;
    15) prevent_ssh_bf;;
    16) prevent_port_scanner;;
    99) install_all;;
    *) echo Option not found;;
esac

echo "Terminado! 

    Gracias por usar DTool by CR1P70 HUN73R
    Github: https://github.com/Bryan-Herrera-DEV
"
