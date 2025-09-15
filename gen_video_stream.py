#!/usr/bin/env python3
from scapy.all import *
import struct

packets = []

# RTSP DESCRIBE
rtsp_describe = IP(src="192.168.1.40", dst="192.168.1.41")/TCP(sport=50000, dport=554)/Raw(load=b"DESCRIBE rtsp://192.168.1.41/stream1 RTSP/1.0\r\n")
packets.append(rtsp_describe)

# RTSP 200 OK
rtsp_ok = IP(src="192.168.1.41", dst="192.168.1.40")/TCP(sport=554, dport=50000)/Raw(load=b"RTSP/1.0 200 OK\r\n")
packets.append(rtsp_ok)

# RTP video stream (high bandwidth)
for i in range(200):
    # Larger payload for video
    rtp_header = struct.pack('!BBHII', 0x80, 96, 2000+i, 90000+i*3000, 0x87654321)  # PT=96 for H.264
    rtp_video = IP(src="192.168.1.41", dst="192.168.1.40")/UDP(sport=20002, dport=20003)/Raw(load=rtp_header + b'\x00'*1400)
    packets.append(rtp_video)

# Multicast video
for i in range(50):
    multicast = IP(src="192.168.1.41", dst="239.1.1.1", ttl=5)/UDP(sport=5004, dport=5004)/Raw(load=b'\x00'*1316)
    packets.append(multicast)

# IGMP join
igmp_join = IP(src="192.168.1.40", dst="239.1.1.1")/Raw(load=b'\x16\x00\x00\x00\xef\x01\x01\x01')
packets.append(igmp_join)

wrpcap("video_stream.pcap", packets)
print("Generated video_stream.pcap")
