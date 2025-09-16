#!/usr/bin/env python3
from scapy.all import *

packets = []
client_ip = "192.168.1.90"
server_ip = "192.168.1.200"
client_port = 60000
server_port = 80

client_seq = 3000000
server_seq = 4000000

# TCP handshake
syn = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                          flags="S", seq=client_seq, window=65535)
syn.time = 0.0
packets.append(syn)
orig_client_seq = client_seq
client_seq += 1

synack = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                              flags="SA", seq=server_seq, ack=client_seq)
synack.time = 0.020
packets.append(synack)
server_seq += 1

ack = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                          flags="A", seq=client_seq, ack=server_seq)
ack.time = 0.021
packets.append(ack)

# Send segments, some will be "lost"
base_time = 0.1
segment_size = 1460  # Full MSS

for i in range(10):
    payload = b'A' * segment_size
    seg = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                               flags="A", seq=client_seq, ack=server_seq)/Raw(load=payload)
    seg.time = base_time + (i * 0.01)
    
    if i not in [3, 7]:  # Segments 3 and 7 are "lost"
        packets.append(seg)
        
        # ACK for received segments (cumulative)
        if i < 3:
            ack_num = orig_client_seq + 1 + ((i + 1) * segment_size)
        elif i < 7:
            ack_num = orig_client_seq + 1 + (3 * segment_size)  # Stuck at segment 3
        else:
            ack_num = orig_client_seq + 1 + (7 * segment_size)  # Stuck at segment 7
            
        ack = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                   flags="A", seq=server_seq, ack=ack_num)
        ack.time = seg.time + 0.020
        packets.append(ack)
        
        # Generate duplicate ACKs for missing segments
        if i == 4 or i == 5 or i == 6:  # DupACKs for missing segment 3
            for j in range(2):  # Two more duplicate ACKs
                dupack = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                              flags="A", seq=server_seq, 
                                                              ack=orig_client_seq + 1 + (3 * segment_size))
                dupack.time = seg.time + 0.020 + (j * 0.001)
                packets.append(dupack)
    
    client_seq += segment_size

# Fast retransmission of segment 3 after 3 duplicate ACKs
retrans_seq = orig_client_seq + 1 + (3 * segment_size)
payload = b'A' * segment_size
retrans1 = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                                flags="A", seq=retrans_seq, ack=server_seq)/Raw(load=payload)
retrans1.time = base_time + 0.15
packets.append(retrans1)

# ACK for retransmitted segment
ack = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                           flags="A", seq=server_seq, ack=retrans_seq + segment_size)
ack.time = retrans1.time + 0.020
packets.append(ack)

# RTO-based retransmission of segment 7
retrans_seq = orig_client_seq + 1 + (7 * segment_size)
retrans2 = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                                flags="A", seq=retrans_seq, ack=server_seq)/Raw(load=payload)
retrans2.time = base_time + 1.0  # After RTO timeout
packets.append(retrans2)

wrpcap("packet_loss.pcap", packets)
print("Generated packet_loss.pcap with retransmissions and duplicate ACKs")
