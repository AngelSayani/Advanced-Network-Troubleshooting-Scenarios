#!/usr/bin/env python3
from scapy.all import *

packets = []

# Successful DNS query
dns_query = IP(src="192.168.1.50", dst="8.8.8.8")/UDP(sport=53421, dport=53)/DNS(qd=DNSQR(qname="google.com"))
dns_response = IP(src="8.8.8.8", dst="192.168.1.50")/UDP(sport=53, dport=53421)/DNS(qr=1, qd=DNSQR(qname="google.com"), an=DNSRR(rrname="google.com", rdata="142.250.185.78"))
packets.extend([dns_query, dns_response])

# NXDOMAIN response
dns_query2 = IP(src="192.168.1.50", dst="8.8.8.8")/UDP(sport=53422, dport=53)/DNS(qd=DNSQR(qname="nonexistent.carvedrock.com"))
dns_nxdomain = IP(src="8.8.8.8", dst="192.168.1.50")/UDP(sport=53, dport=53422)/DNS(qr=1, rcode=3, qd=DNSQR(qname="nonexistent.carvedrock.com"))
packets.extend([dns_query2, dns_nxdomain])

# SERVFAIL response
dns_query3 = IP(src="192.168.1.50", dst="8.8.8.8")/UDP(sport=53423, dport=53)/DNS(qd=DNSQR(qname="internal.carvedrock.com"))
dns_servfail = IP(src="8.8.8.8", dst="192.168.1.50")/UDP(sport=53, dport=53423)/DNS(qr=1, rcode=2, qd=DNSQR(qname="internal.carvedrock.com"))
packets.extend([dns_query3, dns_servfail])

# Large DNS packet (potential tunneling)
large_query = IP(src="192.168.1.55", dst="8.8.8.8")/UDP(sport=53424, dport=53)/DNS(qd=DNSQR(qname="a"*100 + ".tunnel.com"))
packets.append(large_query)

wrpcap("dns_failure.pcap", packets)
print("Generated dns_failure.pcap")
