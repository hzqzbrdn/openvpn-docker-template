#!/bin/sh
# Custom firewall rules applied at container startup
# Add any additional iptables rules here

# Example: allow specific subnet to access internal network
# iptables -A FORWARD -s 10.8.0.0/24 -d 192.168.1.0/24 -j ACCEPT

# Example: block specific client from accessing internal subnet
# iptables -A FORWARD -s 10.8.0.100 -d 192.168.1.0/24 -j DROP
