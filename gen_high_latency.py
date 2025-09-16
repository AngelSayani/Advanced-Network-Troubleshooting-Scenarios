#!/usr/bin/env python3
from scapy.all import *

packets = []
client = "192.168.1.75"
server = "192.168.1.200"

# Create a proper TCP connection with consistent high latency
sport = 50000
dport = 443
client_seq = 1000
server_seq = 5000

# TCP handshake with high latency
syn = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="S", seq=client_seq)
syn.time = 0.0
packets.append(syn)
client_seq += 1

# SYN-ACK with 500ms delay
synack = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="SA", seq=server_seq, ack=client_seq)
synack.time = 0.5  # 500ms RTT
packets.append(synack)
server_seq += 1

# ACK
ack = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="A", seq=client_seq, ack=server_seq)
ack.time = 0.501
packets.append(ack)

# Generate multiple request/response pairs with consistently high RTT
base_time = 1.0
for i in range(20):
    # Client sends data
    data = f"GET /data/{i} HTTP/1.1\r\nHost: api.carvedrock.com\r\n\r\n"
    req = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="PA", seq=client_seq, ack=server_seq)/Raw(load=data)
    req.time = base_time
    packets.append(req)
    client_seq += len(data)
    
    # Server ACK with 500ms delay (high latency network)
    ack = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="A", seq=server_seq, ack=client_seq)
    ack.time = base_time + 0.5
    packets.append(ack)
    
    # Server response
    response = f"HTTP/1.1 200 OK\r\nContent-Length: 15\r\n\r\nResponse {i:02d}"
    resp = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="PA", seq=server_seq, ack=client_seq)/Raw(load=response)
    resp.time = base_time + 0.55  # Small processing time
    packets.append(resp)
    server_seq += len(response)
    
    # Client ACK
    ack = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="A", seq=client_seq, ack=server_seq)
    ack.time = base_time + 1.05  # Another 500ms for return trip
    packets.append(ack)
    
    base_time += 1.5  # Next cycle

# Add example of TCP window scaling issue
# Server advertises very small window
small_win = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="A", seq=server_seq, ack=client_seq, window=100)
small_win.time = base_time
packets.append(small_win)

# Client has to send small segments
for i in range(5):
    # Small data due to window size
    data = "X" * 50  # Only 50 bytes due to small window
    req = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="PA", seq=client_seq, ack=server_seq)/Raw(load=data)
    req.time = base_time + (i * 0.1)
    packets.append(req)
    client_seq += len(data)
    
    # Server ACK
    ack = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="A", seq=server_seq, ack=client_seq, window=100)
    ack.time = base_time + (i * 0.1) + 0.5
    packets.append(ack)

wrpcap("high_latency.pcap", packets)
print("Generated high_latency.pcap with consistent 500ms RTT")
