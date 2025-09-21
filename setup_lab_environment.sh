#!/bin/bash

# Setup Lab Environment Script
# This script downloads and prepares all necessary PCAP files for the lab

echo "Setting up Advanced Network Troubleshooting Lab Environment..."

# Use proxy if available
if [ ! -z "$http_proxy" ]; then
    export http_proxy=$http_proxy
    export https_proxy=$http_proxy
    WGET_PROXY="--proxy=on"
else
    WGET_PROXY="--proxy=off"
fi

# Create necessary directories
mkdir -p /home/ubuntu/lab_files/pcaps
mkdir -p /home/ubuntu/lab_files/logs
mkdir -p /home/ubuntu/lab_files/scripts

# Download PCAP files from Wireshark Wiki only
echo "Downloading PCAP files for lab scenarios..."

# HTTP performance scenario - with ECN showing congestion/delays
wget $WGET_PROXY -q -O /home/ubuntu/lab_files/pcaps/performance_issue.pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/tcp-ecn-sample.pcap"

# Large TCP transfer that may show resets
wget $WGET_PROXY -q -O /home/ubuntu/lab_files/pcaps/tcp_resets.pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/tcp-ethereal-file1.trace"

# DHCP capture
wget $WGET_PROXY -q -O /home/ubuntu/lab_files/pcaps/dhcp.pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dhcp.pcap"

# DNS capture  
wget $WGET_PROXY -q -O /home/ubuntu/lab_files/pcaps/dns.pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dns.cap"

# Combine DHCP and DNS for troubleshooting scenario
if [ -f "/home/ubuntu/lab_files/pcaps/dhcp.pcap" ] && [ -f "/home/ubuntu/lab_files/pcaps/dns.pcap" ]; then
    cat /home/ubuntu/lab_files/pcaps/dhcp.pcap /home/ubuntu/lab_files/pcaps/dns.pcap > /home/ubuntu/lab_files/pcaps/dhcp_dns_issues.pcap 2>/dev/null || \
    cp /home/ubuntu/lab_files/pcaps/dhcp.pcap /home/ubuntu/lab_files/pcaps/dhcp_dns_issues.pcap
fi

# VoIP/SIP with RTP
wget $WGET_PROXY -q -O /home/ubuntu/lab_files/pcaps/voip_quality.pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/aaa.pcap"

# Telnet on standard port (example of clear text protocol)
wget $WGET_PROXY -q -O /home/ubuntu/lab_files/pcaps/non_standard_ports.pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/telnet-raw.pcap"

# HTTP simple capture
wget $WGET_PROXY -q -O /home/ubuntu/lab_files/pcaps/http_simple.pcap \
    "https://wiki.wireshark.org/uploads/27707187aeb30df68e70c8fb9d614981/http.cap"

# Additional SIP/RTP for VoIP analysis
wget $WGET_PROXY -q -O /home/ubuntu/lab_files/pcaps/sip_call.pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/SIP_CALL_RTP_G711"

# Generate simulated NetFlow logs
echo "Generating simulated NetFlow logs..."
if [ -f "/home/ubuntu/Advanced-Network-Troubleshooting-Scenarios/scripts/generate_netflow_logs.sh" ]; then
    bash /home/ubuntu/Advanced-Network-Troubleshooting-Scenarios/scripts/generate_netflow_logs.sh
else
    bash /home/ubuntu/lab_files/scripts/generate_netflow_logs.sh 2>/dev/null || true
fi

# Set proper permissions
chown -R ubuntu:ubuntu /home/ubuntu/lab_files/

echo "Lab environment setup complete!"
echo "PCAP files are available in: /home/ubuntu/lab_files/pcaps/"
echo "Log files are available in: /home/ubuntu/lab_files/logs/"
