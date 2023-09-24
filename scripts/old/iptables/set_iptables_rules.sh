#!/bin/bash

iptables -F
iptables -X
iptables -Z

iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 3 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 11 -j ACCEPT
iptables -A INPUT -p icmp --icmp-type 12 -j ACCEPT
iptables -A INPUT -p tcp --syn --dport 113 -j REJECT --reject-with tcp-reset

iptables -A INPUT -m state --state INVALID -j DROP
iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP
iptables -A OUTPUT -p tcp ! --syn -m state --state NEW -j DROP
iptables -A INPUT -p udp -s 0/0 --dport 138 -j DROP
iptables -A INPUT -p udp -s 0/0 --dport 113 -j DROP
iptables -A INPUT -p udp -j RETURN
iptables -A OUTPUT -p udp -s 0/0 -j ACCEPT

# drop fragmented packages
iptables -A INPUT --fragment -p icmp -j DROP
iptables -A OUTPUT --fragment -p icmp -j DROP

# X server
iptables -A INPUT -p tcp -m tcp --dport 6000:6063 -j DROP --syn

# ssh
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport ssh -j ACCEPT

# ftp/webserver
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 20 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 21 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 443 -j ACCEPT


# Samba
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 137:139 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 426 -j ACCEPT
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 445 -j ACCEPT

# up to 10 bittorrent connections
iptables -A INPUT -p tcp -m state --state NEW -m tcp --dport 6881:6990 -j ACCEPT

# Log stealth scan
iptables -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j LOG --log-prefix "Stealth scan"
iptables -A INPUT -p tcp --tcp-flags ACK,FIN FIN -j DROP

# Reject anything else
iptables -A INPUT -j REJECT --reject-with icmp-port-unreachable

# Reject forwarding
iptables -A FORWARD -j REJECT --reject-with icmp-port-unreachable

# ------- ip6tables -------

ip6tables -F
ip6tables -X
ip6tables -Z

ip6tables -P INPUT DROP
ip6tables -P FORWARD DROP
ip6tables -P OUTPUT ACCEPT

ip6tables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
ip6tables -A INPUT -i lo -j ACCEPT
ip6tables -A INPUT -m conntrack --ctstate INVALID -j DROP
ip6tables -A INPUT -s fe80::/10 -p ipv6-icmp -j ACCEPT
ip6tables -A INPUT -p udp -m conntrack --ctstate NEW -j REJECT --reject-with icmp6-port-unreachable
ip6tables -A INPUT -p tcp -m tcp --tcp-flags FIN,SYN,RST,ACK SYN -m conntrack --ctstate NEW -j REJECT --reject-with tcp-reset
