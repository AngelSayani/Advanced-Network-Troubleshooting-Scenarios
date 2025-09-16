#!/usr/bin/env python3
from scapy.all import *

packets = []

# Scenario 1: Connection to closed port
syn = IP(src="192.168.1.50", dst="192.168.1.100")/TCP(sport=45678, dport=3306, 
                                                       flags="S", seq=1000000)
syn.time = 0.0
packets.append(syn)

rst = IP(src="192.168.1.100", dst="192.168.1.50")/TCP(sport=3306, dport=45678, 
                                                       flags="RA", seq=0, ack=1000001)
rst.time = 0.001
packets.append(rst)

# Scenario 2: Mid-connection reset
client_seq = 2000000
server_seq = 3000000

# Successful connection
syn2 = IP(src="192.168.1.50", dst="192.168.1.100")/TCP(sport=45679, dport=80,
                                                        flags="S", seq=client_seq)
syn2.time = 1.0
packets.append(syn2)

synack2 = IP(src="192.168.1.100", dst="192.168.1.50")/TCP(sport=80, dport=45679,
                                                          flags="SA", seq=server_seq, ack=client_seq+1)
synack2.time = 1.010
packets.append(synack2)

ack2 = IP(src="192.168.1.50", dst="192.168.1.100")/TCP(sport=45679, dport=80,
                                                        flags="A", seq=client_seq+1, ack=server_seq+1)
ack2.time = 1.011
packets.append(ack2)

# HTTP request
http_req = "GET /admin/config HTTP/1.1\r\nHost: 192.168.1.100\r\n\r\n"
data = IP(src="192.168.1.50", dst="192.168.1.100")/TCP(sport=45679, dport=80,
                                                        flags="PA", seq=client_seq+1, 
                                                        ack=server_seq+1)/Raw(load=http_req)
data.time = 1.5
packets.append(data)

# Server immediately sends RST (forbidden access)
rst2 = IP(src="192.168.1.100", dst="192.168.1.50")/TCP(sport=80, dport=45679,
                                                        flags="RA", seq=server_seq+1)
rst2.time = 1.510
packets.append(rst2)

# Client attempts to continue (will be ignored)
attempt = IP(src="192.168.1.50", dst="192.168.1.100")/TCP(sport=45679, dport=80,
                                                           flags="PA", seq=client_seq+1+len(http_req),
                                                           ack=server_seq+1)/Raw(load="More data")
attempt.time = 2.0
packets.append(attempt)

# Another RST
rst3 = IP(src="192.168.1.100", dst="192.168.1.50")/TCP(sport=80, dport=45679,
                                                        flags="R", seq=server_seq+1)
rst3.time = 2.001
packets.append(rst3)

wrpcap("tcp_resets.pcap", packets)
print("Generated tcp_resets.pcap with proper reset scenarios")
