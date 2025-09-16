#!/usr/bin/env python3
from scapy.all import *

packets = []
client = "192.168.1.90"
server = "192.168.1.200"
sport = 60000
dport = 80

# Establish TCP connection
client_seq = 1000
server_seq = 2000

# Handshake
syn = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="S", seq=client_seq)
syn.time = 0.0
packets.append(syn)
client_seq += 1

synack = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="SA", seq=server_seq, ack=client_seq)
synack.time = 0.1
packets.append(synack)
server_seq += 1

ack = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="A", seq=client_seq, ack=server_seq)
ack.time = 0.11
packets.append(ack)

# Send data with gaps (simulating packet loss)
base_time = 0.5
for i in range(20):
    data = f"Packet {i:02d} data segment\r\n"
    pkt = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="PA", seq=client_seq, ack=server_seq)/Raw(load=data)
    pkt.time = base_time + (i * 0.1)
    
    if i not in [5, 10, 15]:  # Simulate loss of packets 5, 10, 15
        packets.append(pkt)
        
        # Server ACK for received packets
        ack = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="A", seq=server_seq, ack=client_seq + len(data))
        ack.time = pkt.time + 0.05
        packets.append(ack)
    
    client_seq += len(data)

# Add retransmissions for lost packets
# Retransmit packet 5
lost_seq = 1000 + 1 + (5 * 28)  # Initial seq + SYN + (5 packets * 28 bytes each)
data = "Packet 05 data segment\r\n"
retrans1 = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="PA", seq=lost_seq, ack=server_seq)/Raw(load=data)
retrans1.time = base_time + 3.0  # Retransmit after timeout
packets.append(retrans1)

# Server ACK
ack = IP(src=server, dst=client)/TCP(sport=dport, dport=sport, flags="A", seq=server_seq, ack=lost_seq + len(data))
ack.time = retrans1.time + 0.05
packets.append(ack)

# Retransmit packet 10
lost_seq = 1000 + 1 + (10 * 28)
data = "Packet 10 data segment\r\n"
retrans2 = IP(src=client, dst=server)/TCP(sport=sport, dport=dport, flags="PA", seq=lost_seq, ack=server_seq)/Raw(load=data)
retrans2.time = base_time + 3.5
packets.append(retrans2)

wrpcap("packet_loss.pcap", packets)
print("Generated packet_loss.pcap with retransmissions")
