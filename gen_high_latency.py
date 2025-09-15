#!/usr/bin/env python3
from scapy.all import *

packets = []
client = "192.168.1.75"
server = "192.168.1.200"

# High RTT connection
base_time = 0
for i in range(10):
    # Each request-response pair with 500ms RTT
    req = IP(src=client, dst=server)/TCP(sport=50000+i, dport=443, flags="PA", seq=1000+i*100)/Raw(load=b"DATA")
    req.time = base_time
    
    resp = IP(src=server, dst=client)/TCP(sport=443, dport=50000+i, flags="PA", ack=1000+i*100+5)
    resp.time = base_time + 0.5  # 500ms RTT
    
    packets.extend([req, resp])
    base_time += 1

# TCP window scaling issue
small_window = IP(src=server, dst=client)/TCP(sport=443, dport=50010, flags="A", window=100)  # Very small window
packets.append(small_window)

wrpcap("high_latency.pcap", packets)
print("Generated high_latency.pcap")
