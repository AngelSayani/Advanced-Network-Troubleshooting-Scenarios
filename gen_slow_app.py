#!/usr/bin/env python3
from scapy.all import *
import random

def create_realistic_pcap():
    packets = []
    
    # Client and server IPs
    client_ip = "192.168.1.100"
    server_ip = "192.168.1.200"
    client_port = 54321
    server_port = 80
    
    # Starting sequence numbers
    client_isn = 1000000
    server_isn = 2000000
    client_seq = client_isn
    server_seq = server_isn
    
    # Base timestamp
    base_time = 0.0
    
    # TCP Handshake with realistic variable RTT
    # SYN
    syn = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port, 
                                                flags="S", seq=client_seq, window=8192,
                                                options=[('MSS', 1460), ('SAckOK', ''), 
                                                        ('Timestamp', (100, 0)), ('WScale', 7)])
    syn.time = base_time
    packets.append(syn)
    client_seq += 1
    
    # SYN-ACK with 185ms delay (realistic network latency with jitter)
    synack = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                   flags="SA", seq=server_seq, ack=client_seq, 
                                                   window=8192, options=[('MSS', 1460), ('SAckOK', ''),
                                                                         ('Timestamp', (200, 100)), ('WScale', 7)])
    synack.time = base_time + 0.185
    packets.append(synack)
    server_seq += 1
    
    # ACK
    ack = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                               flags="A", seq=client_seq, ack=server_seq, window=8192)
    ack.time = base_time + 0.186
    packets.append(ack)
    
    base_time = 0.2
    
    # First HTTP request - normal response time
    http_req1 = "GET /api/data HTTP/1.1\r\nHost: carvedrock.com\r\nUser-Agent: Mozilla/5.0\r\nAccept: */*\r\n\r\n"
    req1 = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                                flags="PA", seq=client_seq, ack=server_seq)/Raw(load=http_req1)
    req1.time = base_time
    packets.append(req1)
    req1_len = len(http_req1)
    
    # Server ACK with 192ms RTT
    ack1 = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                flags="A", seq=server_seq, ack=client_seq + req1_len, window=8192)
    ack1.time = base_time + 0.192
    packets.append(ack1)
    
    # Server response after 250ms (normal processing)
    http_resp1 = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: 45\r\n\r\n{\"status\":\"ok\",\"response_time\":\"250ms\"}"
    resp1 = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                 flags="PA", seq=server_seq, ack=client_seq + req1_len)/Raw(load=http_resp1)
    resp1.time = base_time + 0.250
    packets.append(resp1)
    resp1_len = len(http_resp1)
    
    client_seq += req1_len
    
    # Client ACK
    ack2 = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                               flags="A", seq=client_seq, ack=server_seq + resp1_len)
    ack2.time = base_time + 0.442
    packets.append(ack2)
    
    server_seq += resp1_len
    base_time = 1.0
    
    # Second request - SLOW server processing (3 seconds)
    http_req2 = "GET /api/heavy-query HTTP/1.1\r\nHost: carvedrock.com\r\nUser-Agent: Mozilla/5.0\r\n\r\n"
    req2 = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                                flags="PA", seq=client_seq, ack=server_seq)/Raw(load=http_req2)
    req2.time = base_time
    packets.append(req2)
    req2_len = len(http_req2)
    
    # Server ACK quickly (195ms)
    ack3 = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                flags="A", seq=server_seq, ack=client_seq + req2_len)
    ack3.time = base_time + 0.195
    packets.append(ack3)
    
    # Server response after 3.2 seconds (SLOW processing)
    http_resp2 = "HTTP/1.1 200 OK\r\nContent-Length: 55\r\n\r\n{\"status\":\"ok\",\"processing_time\":\"3000ms\",\"slow\":true}"
    resp2 = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                 flags="PA", seq=server_seq, ack=client_seq + req2_len)/Raw(load=http_resp2)
    resp2.time = base_time + 3.2  # 3 second delay!
    packets.append(resp2)
    resp2_len = len(http_resp2)
    
    client_seq += req2_len
    
    # Client ACK
    ack4 = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                               flags="A", seq=client_seq, ack=server_seq + resp2_len)
    ack4.time = base_time + 3.395
    packets.append(ack4)
    
    server_seq += resp2_len
    base_time = 5.0
    
    # Add some requests with packet loss and retransmissions
    for i in range(3):
        # Request
        http_req = f"GET /api/item/{i} HTTP/1.1\r\nHost: carvedrock.com\r\n\r\n"
        req = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                                   flags="PA", seq=client_seq, ack=server_seq)/Raw(load=http_req)
        req.time = base_time + (i * 2)
        packets.append(req)
        req_len = len(http_req)
        
        if i == 1:  # Simulate packet loss on second request
            # No ACK from server initially
            
            # Client retransmits after 1 second (RTO)
            retrans = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                                          flags="PA", seq=client_seq, ack=server_seq)/Raw(load=http_req)
            retrans.time = base_time + (i * 2) + 1.0
            packets.append(retrans)
            
            # Now server ACKs
            ack = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                       flags="A", seq=server_seq, ack=client_seq + req_len)
            ack.time = base_time + (i * 2) + 1.2
            packets.append(ack)
        else:
            # Normal ACK
            ack = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                       flags="A", seq=server_seq, ack=client_seq + req_len)
            # Variable RTT between 180-210ms
            rtt = random.uniform(0.18, 0.21)
            ack.time = base_time + (i * 2) + rtt
            packets.append(ack)
        
        # Server response with variable processing time
        processing_time = random.uniform(0.3, 0.8) if i != 2 else 2.5  # One slow response
        http_resp = f"HTTP/1.1 200 OK\r\nContent-Length: 20\r\n\r\n{{\"item\":{i},\"data\":\"ok\"}}"
        resp = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                    flags="PA", seq=server_seq, ack=client_seq + req_len)/Raw(load=http_resp)
        resp.time = ack.time + processing_time
        packets.append(resp)
        resp_len = len(http_resp)
        
        client_seq += req_len
        
        # Client ACK
        ack_final = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                                         flags="A", seq=client_seq, ack=server_seq + resp_len)
        ack_final.time = resp.time + random.uniform(0.18, 0.21)
        packets.append(ack_final)
        
        server_seq += resp_len
    
    # Add TCP window scaling issue
    base_time = 12.0
    
    # Server advertises zero window (buffer full)
    zero_win = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                    flags="A", seq=server_seq, ack=client_seq, window=0)
    zero_win.time = base_time
    packets.append(zero_win)
    
    # Client sends window probe
    probe = IP(src=client_ip, dst=server_ip)/TCP(sport=client_port, dport=server_port,
                                                 flags="A", seq=client_seq-1, ack=server_seq)
    probe.time = base_time + 0.5
    packets.append(probe)
    
    # Server still zero window
    zero_win2 = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                     flags="A", seq=server_seq, ack=client_seq, window=0)
    zero_win2.time = base_time + 0.7
    packets.append(zero_win2)
    
    # Server opens window
    open_win = IP(src=server_ip, dst=client_ip)/TCP(sport=server_port, dport=client_port,
                                                    flags="A", seq=server_seq, ack=client_seq, window=8192)
    open_win.time = base_time + 2.0
    packets.append(open_win)
    
    return packets

# Generate the PCAP
packets = create_realistic_pcap()
wrpcap("slow_application.pcap", packets)
print("Generated slow_application.pcap with realistic network issues")
