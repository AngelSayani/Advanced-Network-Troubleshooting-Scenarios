#!/bin/bash

# Setup script for additional lab files
# This script creates simulated monitoring data and prepares the environment

echo "Setting up network analysis lab environment..."

# Create NetFlow simulation data
cat > /home/ubuntu/network_analysis/netflow_data.txt << 'EOF'
=== NetFlow Data Export v5 ===
Flow Summary Report - Generated: 2024-01-15 10:30:00

SrcIP           DstIP           Protocol  SrcPort  DstPort  Packets  Bytes     Flags
192.168.1.100   10.0.0.50       TCP       45123    80       1250     125000    HIGH_LATENCY,RETRANSMISSIONS
192.168.1.100   10.0.0.50       TCP       45124    80       850      85000     HIGH_LATENCY,RETRANSMISSIONS
192.168.1.100   10.0.0.50       TCP       45125    80       923      92300     HIGH_LATENCY,RETRANSMISSIONS
10.0.0.50       192.168.1.100   TCP       80       45123    1189     1783500   NORMAL
10.0.0.50       192.168.1.100   TCP       80       45124    798      1197000   NORMAL
10.0.0.50       192.168.1.100   TCP       80       45125    876      1314000   NORMAL
203.0.113.50    10.0.0.22       TCP       38291    22       45       2250      SYN_FLOOD,BRUTE_FORCE
203.0.113.50    10.0.0.22       TCP       38292    22       45       2250      SYN_FLOOD,BRUTE_FORCE
203.0.113.50    10.0.0.22       TCP       38293    22       45       2250      SYN_FLOOD,BRUTE_FORCE
203.0.113.50    10.0.0.22       TCP       38294    22       45       2250      SYN_FLOOD,BRUTE_FORCE
203.0.113.50    10.0.0.22       TCP       38295    22       48       2400      SYN_FLOOD,BRUTE_FORCE
192.168.1.55    8.8.8.8         UDP       54789    53       3        189       DNS_QUERY
8.8.8.8         192.168.1.55    UDP       53       54789    3        567       DNS_RESPONSE
192.168.1.55    8.8.8.8         UDP       54790    53       3        195       DNS_QUERY
8.8.8.8         192.168.1.55    UDP       53       54790    3        1890      DNS_RESPONSE,LARGE_RESPONSE
192.168.1.200   10.0.0.80       TCP       52341    443      234      23400     SSL_HANDSHAKE
10.0.0.80       192.168.1.200   TCP       443      52341    267      401000    SSL_DATA
172.16.0.10     239.255.255.250 UDP       1900     1900     50       7500      MULTICAST,SSDP
192.168.1.100   10.0.0.1        TCP       49823    445      15       750       PORT_SCAN
192.168.1.100   10.0.0.1        TCP       49824    3389     15       750       PORT_SCAN
192.168.1.100   10.0.0.1        TCP       49825    8080     15       750       PORT_SCAN
192.168.1.100   10.0.0.2        TCP       49826    445      15       750       PORT_SCAN
192.168.1.100   10.0.0.3        TCP       49827    445      15       750       PORT_SCAN

Flow Statistics:
Total Flows: 23
Total Packets: 5,892
Total Bytes: 6,234,456
Average Flow Duration: 3.2 seconds
Flows with HIGH_LATENCY: 3
Flows with RETRANSMISSIONS: 3
Flows with PACKET_LOSS: 0
Suspicious Flows: 8 (PORT_SCAN: 5, BRUTE_FORCE: 5, SYN_FLOOD: 5)
EOF

# Create monitoring alerts correlation data
cat > /home/ubuntu/network_analysis/monitoring_alerts.txt << 'EOF'
=== Network Monitoring System Alerts ===
Alert Log - Time Range: 2024-01-15 10:00:00 - 11:00:00

Timestamp              Severity  Type                Alert_ID  Description
2024-01-15 10:05:23   HIGH      PACKET_LOSS        A001      Interface eth0: 5% packet loss detected
2024-01-15 10:08:45   MEDIUM    HIGH_LATENCY       A002      RTT to 10.0.0.50 exceeded threshold (>200ms)
2024-01-15 10:12:10   HIGH      CONNECTION_RESET   A003      Multiple TCP RST packets from 10.0.0.50
2024-01-15 10:15:33   CRITICAL  SERVICE_DOWN       A004      HTTP service on 10.0.0.50:80 not responding
2024-01-15 10:18:55   HIGH      BRUTE_FORCE        A005      SSH brute force detected from 203.0.113.50
2024-01-15 10:22:18   MEDIUM    DNS_FAILURE        A006      DNS resolution failures for internal.company.com
2024-01-15 10:25:40   LOW       DHCP_EXHAUSTION    A007      DHCP pool 80% utilized
2024-01-15 10:28:02   HIGH      PORT_SCAN          A008      Vertical port scan detected from 192.168.1.100
2024-01-15 10:31:25   MEDIUM    BANDWIDTH_HIGH     A009      Interface eth0: 85% bandwidth utilization
2024-01-15 10:34:47   HIGH      TCP_RETRANS        A010      Retransmission rate exceeded 3% threshold
2024-01-15 10:38:09   CRITICAL  DDOS_SUSPECTED     A011      SYN flood detected targeting 10.0.0.22
2024-01-15 10:41:31   MEDIUM    SSL_CERT_EXPIRE    A012      SSL certificate expires in 7 days for 10.0.0.80
2024-01-15 10:44:54   LOW       MULTICAST_STORM    A013      Excessive multicast traffic on VLAN 100
2024-01-15 10:48:16   HIGH      APPLICATION_SLOW   A014      Response time >5s for application server
2024-01-15 10:51:38   MEDIUM    ROUTING_CHANGE     A015      BGP route flap detected for prefix 10.0.0.0/24

ALERT 2024-01-15 10:31:00 - CRITICAL: Network performance degradation detected
ALERT 2024-01-15 10:32:00 - HIGH: Multiple security events from 192.168.1.100
ALERT 2024-01-15 10:33:00 - HIGH: TCP performance issues affecting multiple hosts

Summary:
Total Alerts: 18
Critical: 2
High: 8
Medium: 6
Low: 2
EOF

# Create README for the repository
cat > /home/ubuntu/network_analysis/README.md << 'EOF'
# Advanced Network Troubleshooting Lab Files

This repository contains all necessary files for the Advanced Network Troubleshooting Scenarios lab.

## File Structure

### PCAP Files
- `slow_download.pcap` - TCP performance issues with retransmissions
- `tcp_problems.pcap` - Various TCP anomalies including resets
- `http_latency.pcap` - HTTP transactions with high latency
- `retransmissions.pcap` - Packet loss and retransmission patterns
- `dhcp_failure.pcap` - DHCP configuration problems
- `dns_problems.pcap` - DNS resolution failures and timeouts
- `unusual_ports.pcap` - Services on non-standard ports

### Data Files
- `netflow_data.txt` - Simulated NetFlow export data
- `monitoring_alerts.txt` - Correlated monitoring system alerts

### Scripts
- `setup_pcaps.sh` - Environment setup script

## Lab Objectives

1. **Diagnose Performance Bottlenecks**
   - Identify packet loss and latency issues
   - Analyze TCP window scaling problems
   - Investigate application response times

2. **Apply Troubleshooting Methodologies**
   - Use expert analysis tools
   - Correlate multiple data sources
   - Create systematic troubleshooting plans

3. **Troubleshoot Protocol Issues**
   - Diagnose DHCP failures
   - Analyze DNS problems
   - Detect services on non-standard ports

## Usage

The lab environment automatically downloads and configures these files during initialization.
EOF

echo "Lab environment setup complete!"
echo "Files created in /home/ubuntu/network_analysis/"
ls -la /home/ubuntu/network_analysis/
