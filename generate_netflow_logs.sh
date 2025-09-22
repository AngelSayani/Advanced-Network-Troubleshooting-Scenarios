#!/bin/bash

# Generate Simulated NetFlow Logs for Lab
# These logs correlate with the PCAP scenarios using actual IPs from captures

LOG_DIR="/home/ubuntu/lab_files/logs"
mkdir -p $LOG_DIR

# Generate NetFlow-style logs using IPs from actual sip_call.pcap capture
cat > $LOG_DIR/netflow_performance.log << 'EOF'
2024-01-15 10:23:38 SrcIP=200.57.7.194 DstIP=200.57.7.204 SrcPort=80 DstPort=4558 Proto=TCP Packets=245 Bytes=17249 Duration=1.2s Flags=FIN
2024-01-15 10:23:45 SrcIP=200.57.7.194 DstIP=200.57.7.204 SrcPort=80 DstPort=4565 Proto=TCP Packets=60 Bytes=17249 Duration=0.68s Flags=FIN
2024-01-15 10:23:46 SrcIP=200.57.7.194 DstIP=200.57.7.204 SrcPort=80 DstPort=4190 Proto=TCP Packets=8 Bytes=480 Duration=0.003s Flags=RST
2024-01-15 10:24:12 SrcIP=200.57.7.194 DstIP=200.57.7.204 SrcPort=80 DstPort=4557 Proto=TCP Packets=892 Bytes=456234 Duration=1.5s Flags=FIN
2024-01-15 10:25:45 SrcIP=200.57.7.194 DstIP=200.57.7.204 SrcPort=80 DstPort=4200 Proto=TCP Packets=145 Bytes=9208 Duration=0.03s Flags=RST
2024-01-15 10:26:18 SrcIP=200.57.7.194 DstIP=200.57.7.204 SrcPort=80 DstPort=4207 Proto=TCP Packets=632 Bytes=42351 Duration=0.03s Flags=RST
EOF

# Generate alerts log with IPs from captures
cat > $LOG_DIR/network_alerts.log << 'EOF'
2024-01-15 10:23:00 ALERT: High latency detected on link to 200.57.7.204 (avg RTT: 450ms)
2024-01-15 10:23:45 WARNING: Multiple TCP resets from 200.57.7.194 to port 5060 (SIP)
2024-01-15 10:23:46 WARNING: Rapid connection resets detected - possible firewall intervention
2024-01-15 10:25:30 ALERT: Packet loss detected: 12% loss on connection to 200.57.7.204
2024-01-15 10:26:00 WARNING: SIP registration failures from 200.57.7.194
2024-01-15 10:27:00 ALERT: Multiple RST packets with Win=0 detected - connection forcibly closed
2024-01-15 10:28:00 WARNING: Port numbers higher than 4000 (Secure SIP) showing repeated connection failures
EOF

# Generate DNS query log
cat > $LOG_DIR/dns_queries.log << 'EOF'
2024-01-15 10:23:01 Query: A sip.carvedrock.com from 200.57.7.194 - SUCCESS (200.57.7.204)
2024-01-15 10:23:05 Query: A www.carvedrock.com from 200.57.7.194 - SUCCESS (203.0.113.50)
2024-01-15 10:23:12 Query: PTR 200.57.7.204 from 200.57.7.194 - TIMEOUT
2024-01-15 10:23:18 Query: A voip.carvedrock.com from 200.57.7.194 - SUCCESS (200.57.7.204)
2024-01-15 10:23:25 Query: AAAA sip.carvedrock.com from 200.57.7.194 - NXDOMAIN
2024-01-15 10:23:30 Query: SRV _sip._tcp.carvedrock.com from 200.57.7.194 - SUCCESS
EOF

# Generate DHCP events log (keeping generic as not related to SIP capture)
cat > $LOG_DIR/dhcp_events.log << 'EOF'
2024-01-15 10:20:00 DHCPDISCOVER from 00:11:22:33:44:55 via eth0
2024-01-15 10:20:01 DHCPOFFER on 192.168.1.110 to 00:11:22:33:44:55 via eth0
2024-01-15 10:20:02 DHCPREQUEST for 192.168.1.110 from 00:11:22:33:44:55 via eth0
2024-01-15 10:20:03 DHCPACK on 192.168.1.110 to 00:11:22:33:44:55 via eth0
2024-01-15 10:22:00 DHCPDISCOVER from 00:aa:bb:cc:dd:ee via eth0
2024-01-15 10:22:05 DHCPDISCOVER from 00:aa:bb:cc:dd:ee via eth0 (retry)
2024-01-15 10:22:10 DHCPDISCOVER from 00:aa:bb:cc:dd:ee via eth0 (retry)
2024-01-15 10:22:15 ERROR: No free leases available for subnet 192.168.1.0/24
EOF

# Set proper permissions
chown -R ubuntu:ubuntu $LOG_DIR

echo "NetFlow and correlation logs generated successfully!"
