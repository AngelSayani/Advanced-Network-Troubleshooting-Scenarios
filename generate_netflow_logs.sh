#!/bin/bash

# Generate Simulated NetFlow Logs for Lab
# These logs correlate with the PCAP scenarios

LOG_DIR="/home/ubuntu/lab_files/logs"
mkdir -p $LOG_DIR

# Generate NetFlow-style logs for performance issues
cat > $LOG_DIR/netflow_performance.log << 'EOF'
2024-01-15 10:23:45 SrcIP=192.168.1.100 DstIP=203.0.113.50 SrcPort=45234 DstPort=80 Proto=TCP Packets=1523 Bytes=2145632 Duration=45.3s Flags=FIN
2024-01-15 10:24:12 SrcIP=192.168.1.101 DstIP=203.0.113.50 SrcPort=45235 DstPort=443 Proto=TCP Packets=892 Bytes=456234 Duration=120.5s Flags=RST
2024-01-15 10:25:03 SrcIP=192.168.1.102 DstIP=203.0.113.51 SrcPort=45236 DstPort=80 Proto=TCP Packets=3421 Bytes=5234123 Duration=15.2s Flags=FIN
2024-01-15 10:25:45 SrcIP=192.168.1.100 DstIP=203.0.113.50 SrcPort=45237 DstPort=80 Proto=TCP Packets=245 Bytes=34521 Duration=180.7s Flags=RST
2024-01-15 10:26:18 SrcIP=192.168.1.103 DstIP=203.0.113.52 SrcPort=45238 DstPort=8080 Proto=TCP Packets=5632 Bytes=8923451 Duration=8.9s Flags=FIN
EOF

# Generate alerts log
cat > $LOG_DIR/network_alerts.log << 'EOF'
2024-01-15 10:23:00 ALERT: High latency detected on link to 203.0.113.50 (avg RTT: 450ms)
2024-01-15 10:24:15 WARNING: Multiple TCP resets from 192.168.1.101
2024-01-15 10:25:30 ALERT: Packet loss detected: 12% loss on subnet 192.168.1.0/24
2024-01-15 10:26:00 WARNING: DNS resolution failures for internal.carvedrock.com
2024-01-15 10:27:00 ALERT: VoIP quality degradation detected (jitter > 50ms)
2024-01-15 10:28:00 WARNING: Unusual traffic on port 8888 from 192.168.1.105
EOF

# Generate DNS query log
cat > $LOG_DIR/dns_queries.log << 'EOF'
2024-01-15 10:23:01 Query: A internal.carvedrock.com from 192.168.1.100 - NXDOMAIN
2024-01-15 10:23:05 Query: A www.carvedrock.com from 192.168.1.100 - SUCCESS (203.0.113.50)
2024-01-15 10:23:12 Query: PTR 192.168.1.1 from 192.168.1.101 - TIMEOUT
2024-01-15 10:23:18 Query: A mail.carvedrock.com from 192.168.1.102 - SUCCESS (203.0.113.51)
2024-01-15 10:23:25 Query: AAAA internal.carvedrock.com from 192.168.1.100 - NXDOMAIN
2024-01-15 10:23:30 Query: A database.carvedrock.com from 192.168.1.103 - SERVFAIL
EOF

# Generate DHCP events log
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
