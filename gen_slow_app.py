#!/usr/bin/env python3
from scapy.all import *

packets = []

# Client and server IPs
client = "192.168.1.100"
server = "192.168.1.200"

# TCP handshake
syn = IP(src=client, dst=server)/TCP(sport=54321, dport=80, flags="S", seq=1000)
synack = IP(src=server, dst=client)/TCP(sport=80, dport=54321, flags="SA", seq=2000, ack=1001)
ack = IP(src=client, dst=server)/TCP(sport=54321, dport=80, flags="A", seq=1001, ack=2001)

# Add timestamps to simulate delay
syn.time = 1.0
synack.time = 1.2  # 200ms network delay
ack.time = 1.21

packets.extend([syn, synack, ack])

# HTTP request
http_req = IP(src=client, dst=server)/TCP(sport=54321, dport=80, flags="PA", seq=1001, ack=2001)/Raw(load=b"GET /api/data HTTP/1.1\r\nHost: carvedrock.com\r\n\r\n")
http_req.time = 1.22
packets.append(http_req)

# Delayed HTTP response (3 second server processing)
http_resp = IP(src=server, dst=client)/TCP(sport=80, dport=54321, flags="PA", seq=2001, ack=1047)/Raw(load=b"HTTP/1.1 200 OK\r\nContent-Length: 50\r\n\r\n{\"status\":\"success\",\"processing_time\":\"3000ms\"}")
http_resp.time = 4.22  # 3 second delay indicates server issue
packets.append(http_resp)

# TCP retransmissions to show packet loss
retrans1 = IP(src=client, dst=server)/TCP(sport=54322, dport=80, flags="S", seq=5000)
retrans1.time = 5.0
retrans2 = IP(src=client, dst=server)/TCP(sport=54322, dport=80, flags="S", seq=5000)  # Same seq number = retransmission
retrans2.time = 6.0
packets.extend([retrans1, retrans2])

wrpcap("slow_application.pcap", packets)
print("Generated slow_application.pcap")
