#!/usr/bin/env python3
from scapy.all import *

packets = []

# Connection attempt to closed port
client = "192.168.1.50"
server = "192.168.1.100"

# SYN to closed port
syn = IP(src=client, dst=server)/TCP(sport=45678, dport=3306, flags="S")
rst = IP(src=server, dst=client)/TCP(sport=3306, dport=45678, flags="RA")
packets.extend([syn, rst])

# Established connection then RST (application crash)
syn2 = IP(src=client, dst=server)/TCP(sport=45679, dport=80, flags="S", seq=1000)
synack2 = IP(src=server, dst=client)/TCP(sport=80, dport=45679, flags="SA", seq=2000, ack=1001)
ack2 = IP(src=client, dst=server)/TCP(sport=45679, dport=80, flags="A", seq=1001, ack=2001)
data = IP(src=client, dst=server)/TCP(sport=45679, dport=80, flags="PA", seq=1001, ack=2001)/Raw(load=b"GET / HTTP/1.1\r\n")
rst2 = IP(src=server, dst=client)/TCP(sport=80, dport=45679, flags="R", seq=2001)
packets.extend([syn2, synack2, ack2, data, rst2])

wrpcap("tcp_resets.pcap", packets)
print("Generated tcp_resets.pcap")
