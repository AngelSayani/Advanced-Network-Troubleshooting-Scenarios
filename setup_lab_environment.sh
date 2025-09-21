#!/bin/bash

# Setup Lab Environment Script
# This script downloads and prepares all necessary PCAP files for the lab

echo "Setting up Advanced Network Troubleshooting Lab Environment..."

# Create necessary directories
mkdir -p /home/ubuntu/lab_files/pcaps
mkdir -p /home/ubuntu/lab_files/logs
mkdir -p /home/ubuntu/lab_files/scripts

# Download PCAP files from approved sources
echo "Downloading PCAP files for lab scenarios..."

# Performance bottleneck scenario - HTTP with delays
wget -q -O /home/ubuntu/lab_files/pcaps/performance_issue.pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/http-wireshark-file00002.pcap.gz"
gunzip -f /home/ubuntu/lab_files/pcaps/performance_issue.pcap.gz 2>/dev/null || true

# TCP resets scenario
wget -q -O /home/ubuntu/lab_files/pcaps/tcp_resets.pcap \
    "https://www.netresec.com/files/pcap/ftp-example.pcap"

# DHCP and DNS issues
wget -q -O /home/ubuntu/lab_files/pcaps/dhcp_dns_issues.pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dhcp-and-dnsv1.pcap.gz"
gunzip -f /home/ubuntu/lab_files/pcaps/dhcp_dns_issues.pcap.gz 2>/dev/null || true

# VoIP quality issues - SIP and RTP
wget -q -O /home/ubuntu/lab_files/pcaps/voip_quality.pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/rtp_example.pcap.gz"
gunzip -f /home/ubuntu/lab_files/pcaps/voip_quality.pcap.gz 2>/dev/null || true

# Non-standard ports traffic
wget -q -O /home/ubuntu/lab_files/pcaps/non_standard_ports.pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/telnet-raw.pcap"

# Additional backup downloads for comprehensive scenarios
wget -q -O /home/ubuntu/lab_files/pcaps/http_performance.pcap \
    "https://www.netresec.com/files/pcap/http.pcap"

wget -q -O /home/ubuntu/lab_files/pcaps/dns_issues.pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dns.cap"

# Generate simulated NetFlow logs
echo "Generating simulated NetFlow logs..."
bash /home/ubuntu/Advanced-Network-Troubleshooting-Scenarios/scripts/generate_netflow_logs.sh

# Set proper permissions
chown -R ubuntu:ubuntu /home/ubuntu/lab_files/

echo "Lab environment setup complete!"
echo "PCAP files are available in: /home/ubuntu/lab_files/pcaps/"
echo "Log files are available in: /home/ubuntu/lab_files/logs/"
