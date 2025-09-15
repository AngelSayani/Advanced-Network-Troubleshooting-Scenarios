#!/usr/bin/env python3
from scapy.all import *

packets = []

# DHCP Discover
discover = Ether(dst="ff:ff:ff:ff:ff:ff")/IP(src="0.0.0.0", dst="255.255.255.255")/UDP(sport=68, dport=67)/BOOTP(chaddr=b'\x00\x11\x22\x33\x44\x55')/DHCP(options=[("message-type", "discover"), "end"])
packets.append(discover)

# DHCP Offer
offer = Ether()/IP(src="192.168.1.1", dst="255.255.255.255")/UDP(sport=67, dport=68)/BOOTP(op=2, yiaddr="192.168.1.100", chaddr=b'\x00\x11\x22\x33\x44\x55')/DHCP(options=[("message-type", "offer"), ("subnet_mask", "255.255.255.0"), ("router", "192.168.1.1"), ("name_server", "8.8.8.8"), "end"])
packets.append(offer)

# DHCP Request
request = Ether(dst="ff:ff:ff:ff:ff:ff")/IP(src="0.0.0.0", dst="255.255.255.255")/UDP(sport=68, dport=67)/BOOTP(chaddr=b'\x00\x11\x22\x33\x44\x55')/DHCP(options=[("message-type", "request"), ("requested_addr", "192.168.1.100"), "end"])
packets.append(request)

# No ACK - simulating failure
discover2 = Ether(dst="ff:ff:ff:ff:ff:ff")/IP(src="0.0.0.0", dst="255.255.255.255")/UDP(sport=68, dport=67)/BOOTP(chaddr=b'\x00\x11\x22\x33\x44\x55')/DHCP(options=[("message-type", "discover"), "end"])
packets.append(discover2)

wrpcap("dhcp_failure.pcap", packets)
print("Generated dhcp_failure.pcap")
