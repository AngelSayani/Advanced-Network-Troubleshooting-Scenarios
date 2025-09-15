#!/usr/bin/env python3
from scapy.all import *

packets = []
client = "192.168.1.90"
server = "192.168.1.200"

# TCP stream with gaps showing packet loss
seq_num = 1000
for i in range(20):
    if i == 5 or i == 10 or i == 15:  # Skip these to simulate loss
        continue
    pkt = IP(src=client, dst=server)/TCP(sport=60000, dport=80, seq=seq_num, flags="A")
    packets.append(pkt)
    seq_num += 100

# Add retransmissions
retrans1 = IP(src=client, dst=server)/TCP(sport=60000, dport=80, seq=1500, flags="A")
retrans2 = IP(src=client, dst=server)/TCP(sport=60000, dport=80, seq=2000, flags="A")
packets.extend([retrans1, retrans2])

wrpcap("packet_loss.pcap", packets)
print("Generated packet_loss.pcap")
