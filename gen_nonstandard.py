#!/usr/bin/env python3
from scapy.all import *

packets = []

# HTTP on port 8888 instead of 80
http_8888 = IP(src="192.168.1.60", dst="192.168.1.70")/TCP(sport=40000, dport=8888)/Raw(load=b"GET / HTTP/1.1\r\nHost: hidden.carvedrock.com\r\n\r\n")
packets.append(http_8888)

# SSH on port 2222 instead of 22
ssh_2222 = IP(src="192.168.1.60", dst="192.168.1.70")/TCP(sport=40001, dport=2222)/Raw(load=b"SSH-2.0-OpenSSH_8.0\r\n")
packets.append(ssh_2222)

# HTTPS on port 8443 instead of 443
tls_hello = IP(src="192.168.1.60", dst="192.168.1.70")/TCP(sport=40002, dport=8443)/Raw(load=b'\x16\x03\x01\x00\x50')
packets.append(tls_hello)

# Unknown service on port 31337 (common backdoor port)
backdoor = IP(src="192.168.1.60", dst="192.168.1.70")/TCP(sport=40003, dport=31337)/Raw(load=b"BACKDOOR_COMMAND\r\n")
packets.append(backdoor)

wrpcap("nonstandard_ports.pcap", packets)
print("Generated nonstandard_ports.pcap")
