#!/usr/bin/env python3
from scapy.all import *

packets = []

# Scenario 1: Connection to closed port
client = "192.168.1.50"
server = "192.168.1.100"

# SYN to closed port 3306 (MySQL)
syn = IP(src=client, dst=server)/TCP(sport=45678, dport=3306, flags="S", seq=1000)
syn.time = 0.0
packets.append(syn)

# Immediate RST+ACK from server (port closed)
rst = IP(src=server, dst=client)/TCP(sport=3306, dport=45678, flags="RA", seq=0, ack=1001)
rst.time = 0.001  # Very fast response for closed port
packets.append(rst)

# Scenario 2: Established connection then RST (application crash)
client = "192.168.1.50"
server = "192.168.1.100"
sport = 45679
dport = 80

# Successful handshake
syn2 = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="S", seq=2000)
syn2.time = 1.0
packets.append(syn2)

synack2 = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="SA", seq=3000, ack=2001)
synack2.time = 1.01
packets.append(synack2)

ack2 = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="A", seq=2001, ack=3001)
ack2.time = 1.02
packets.append(ack2)

# Client sends HTTP request
http_req = "GET /admin HTTP/1.1\r\nHost: 192.168.1.100\r\n\r\n"
data = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="PA", seq=2001, ack=3001)/Raw(load=http_req)
data.time = 1.5
packets.append(data)

# Server ACKs the data
ack3 = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="A", seq=3001, ack=2001+len(http_req))
ack3.time = 1.51
packets.append(ack3)

# Server sends RST (application crashed or security policy)
rst2 = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="R", seq=3001)
rst2.time = 1.52
packets.append(rst2)

# Scenario 3: Client tries to continue after RST
attempt = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="PA", seq=2001+len(http_req), ack=3001)/Raw(load="More data")
attempt.time = 2.0
packets.append(attempt)

# Another RST from server
rst3 = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="R", seq=3001)
rst3.time = 2.01
packets.append(rst3)

wrpcap("tcp_resets.pcap", packets)
print("Generated tcp_resets.pcap with proper reset scenarios")
