#!/bin/bash

# Lab initialization script for Advanced Network Troubleshooting Scenarios
echo "=== Initializing Network Troubleshooting Lab Environment ==="

# Check if we're in the right directory
if [ ! -d "/home/ubuntu/network_troubleshooting" ]; then
    mkdir -p /home/ubuntu/network_troubleshooting
fi

cd /home/ubuntu/network_troubleshooting

# Check for required PCAP files
REQUIRED_FILES="performance_issue.pcap tcp_problems.pcap dns_problems.pcap"
MISSING_FILES=""

for file in $REQUIRED_FILES; do
    if [ ! -f "$file" ]; then
        MISSING_FILES="$MISSING_FILES $file"
    fi
done

if [ ! -z "$MISSING_FILES" ]; then
    echo "Warning: Some PCAP files are missing:$MISSING_FILES"
    echo "The lab setup will attempt to download them..."
fi

# Verify Wireshark is installed and accessible
if ! command -v wireshark &> /dev/null; then
    echo "ERROR: Wireshark is not installed or not in PATH"
    exit 1
fi

# Check Wireshark capabilities
echo "Wireshark version: $(wireshark -v 2>&1 | head -1)"

# Verify user can capture packets
if groups | grep -q wireshark; then
    echo "User is in wireshark group - packet capture enabled"
else
    echo "WARNING: User not in wireshark group - some features may be limited"
fi

echo ""
echo "=== Lab environment ready ==="
echo "Current directory: $(pwd)"
echo "Available PCAP files:"
ls -lh *.pcap 2>/dev/null || echo "No PCAP files found yet"
echo ""
echo "NetFlow alerts log:"
ls -lh *.log 2>/dev/null || echo "No log files found yet"
echo ""
echo "You can now proceed with the lab exercises."
