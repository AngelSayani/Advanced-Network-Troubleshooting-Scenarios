#!/usr/bin/env python3
from scapy.all import *
import time

packets = []

# Client and server IPs
client = "192.168.1.100"
server = "192.168.1.200"
sport = 54321
dport = 80

# Create a proper TCP stream with timestamps for RTT calculation
# Initial sequence numbers
client_seq = 1000
server_seq = 2000

# TCP handshake with realistic timing
syn = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="S", seq=client_seq)
syn.time = 1.0
packets.append(syn)
client_seq += 1

synack = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="SA", seq=server_seq, ack=client_seq)
synack.time = 1.200  # 200ms RTT for handshake
packets.append(synack)
server_seq += 1

ack = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="A", seq=client_seq, ack=server_seq)
ack.time = 1.201
packets.append(ack)

# HTTP request
http_request = "GET /api/data HTTP/1.1\r\nHost: carvedrock.com\r\nConnection: keep-alive\r\n\r\n"
req = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="PA", seq=client_seq, ack=server_seq)/Raw(load=http_request)
req.time = 1.5
packets.append(req)
client_seq += len(http_request)

# ACK from server (immediate)
ack2 = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="A", seq=server_seq, ack=client_seq)
ack2.time = 1.7  # 200ms network delay
packets.append(ack2)

# HTTP response after 3 second processing delay
http_response = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: 50\r\n\r\n{\"status\":\"success\",\"processing_time\":\"3000ms\"}"
resp = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="PA", seq=server_seq, ack=client_seq)/Raw(load=http_response)
resp.time = 4.7  # 3 second server processing + 200ms network
packets.append(resp)
server_seq += len(http_response)

# Client ACK
ack3 = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="A", seq=client_seq, ack=server_seq)
ack3.time = 4.9  # 200ms RTT
packets.append(ack3)

# Add more request/response pairs to show pattern
for i in range(5):
    # Request
    req_data = f"GET /api/item/{i} HTTP/1.1\r\nHost: carvedrock.com\r\n\r\n"
    req = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="PA", seq=client_seq, ack=server_seq)/Raw(load=req_data)
    req.time = 5.0 + (i * 2)
    packets.append(req)
    old_client_seq = client_seq
    client_seq += len(req_data)
    
    # Server ACK
    ack = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="A", seq=server_seq, ack=client_seq)
    ack.time = 5.0 + (i * 2) + 0.2  # 200ms RTT
    packets.append(ack)
    
    # Response with varying delays
    resp_data = f"HTTP/1.1 200 OK\r\nContent-Length: 20\r\n\r\nItem {i} data here"
    resp = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="PA", seq=server_seq, ack=client_seq)/Raw(load=resp_data)
    if i == 2:
        resp.time = 5.0 + (i * 2) + 2.5  # 2.5 second delay for item 2
    else:
        resp.time = 5.0 + (i * 2) + 0.5  # 500ms normal response
    packets.append(resp)
    old_server_seq = server_seq
    server_seq += len(resp_data)
    
    # Client ACK
    ack = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="A", seq=client_seq, ack=server_seq)
    ack.time = resp.time + 0.2
    packets.append(ack)

wrpcap("slow_application.pcap", packets)
print("Generated slow_application.pcap with proper RTT data")
