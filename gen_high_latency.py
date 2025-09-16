#!/usr/bin/env python3
from scapy.all import *
import random

packets = []
client_ip = "192.168.1.75"
server_ip = "192.168.1.200"
client_port = 50000
server_port = 443

client_seq = 1000000
server_seq = 2000000

# TCP handshake with high but variable latency
syn = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port, 
                                           flags="S", seq=client_seq, window=64240,
                                           options=[('MSS', 1460), ('WScale', 8)])
syn.time = 0.0
packets.append(syn)
client_seq += 1

# High latency SYN-ACK (485ms - simulating satellite or overseas connection)
synack = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                              flags="SA", seq=server_seq, ack=client_seq, window=64240)
synack.time = 0.485
packets.append(synack)
server_seq += 1

# ACK
ack = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                          flags="A", seq=client_seq, ack=server_seq)
ack.time = 0.486
packets.append(ack)

# Generate traffic with consistently high but variable RTT
base_time = 1.0
for i in range(15):
    # HTTPS request (encrypted payload)
    payload = b'\x17\x03\x03\x00\x50' + b'\x00' * 80  # TLS application data
    req = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                               flags="PA", seq=client_seq, ack=server_seq)/Raw(load=payload)
    req.time = base_time
    packets.append(req)
    req_len = len(payload)
    
    # High latency ACK (450-550ms with jitter)
    rtt = random.uniform(0.45, 0.55)
    ack = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                               flags="A", seq=server_seq, ack=client_seq + req_len)
    ack.time = base_time + rtt
    packets.append(ack)
    
    # Response with additional processing delay
    response = b'\x17\x03\x03\x00\x80' + b'\x00' * 128  # TLS response
    resp = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                flags="PA", seq=server_seq, ack=client_seq + req_len)/Raw(load=response)
    resp.time = base_time + rtt + random.uniform(0.05, 0.15)
    packets.append(resp)
    resp_len = len(response)
    
    client_seq += req_len
    
    # Client ACK with high RTT
    ack2 = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                                flags="A", seq=client_seq, ack=server_seq + resp_len)
    ack2.time = resp.time + rtt
    packets.append(ack2)
    
    server_seq += resp_len
    base_time += 2.0

# Add small window scenario
small_win = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                  flags="A", seq=server_seq, ack=client_seq, window=256)
small_win.time = base_time
packets.append(small_win)

wrpcap("high_latency.pcap", packets)
print("Generated high_latency.pcap with consistent high latency")
