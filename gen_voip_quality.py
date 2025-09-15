#!/usr/bin/env python3
from scapy.all import *
import struct

packets = []

# SIP INVITE (simplified)
sip_invite = IP(src="192.168.1.30", dst="192.168.1.31")/UDP(sport=5060, dport=5060)/Raw(load=b"INVITE sip:1002@192.168.1.31 SIP/2.0\r\n")
packets.append(sip_invite)

# SIP 200 OK
sip_ok = IP(src="192.168.1.31", dst="192.168.1.30")/UDP(sport=5060, dport=5060)/Raw(load=b"SIP/2.0 200 OK\r\n")
packets.append(sip_ok)

# RTP stream with jitter and packet loss
base_time = 0
seq = 1000
timestamp = 160
ssrc = 0x12345678

for i in range(100):
    # Skip some packets to simulate loss
    if i % 15 == 0:
        continue
        
    # RTP header: V=2, P=0, X=0, CC=0, M=0, PT=0 (PCMU), Seq, Timestamp, SSRC
    rtp_header = struct.pack('!BBHII', 0x80, 0, seq, timestamp, ssrc)
    
    rtp = IP(src="192.168.1.30", dst="192.168.1.31")/UDP(sport=20000, dport=20001)/Raw(load=rtp_header + b'\x00'*160)
    
    # Add variable delay for jitter
    if i % 10 == 0:
        rtp.time = base_time + 0.05  # 50ms jitter spike
    else:
        rtp.time = base_time + 0.02  # Normal 20ms interval
    
    packets.append(rtp)
    seq += 1
    timestamp += 160
    base_time += 0.02

wrpcap("voip_quality.pcap", packets)
print("Generated voip_quality.pcap")
