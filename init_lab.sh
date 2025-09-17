#!/bin/bash

# Lab Initialization Script
# This script ensures all lab files are present and ready

echo "Initializing Advanced Network Troubleshooting Lab..."
echo "====================================================="

# Check if running as ubuntu user
if [ "$USER" != "ubuntu" ]; then
    echo "Warning: Running as $USER instead of ubuntu"
fi

# Verify network_analysis directory exists
if [ ! -d "/home/ubuntu/network_analysis" ]; then
    echo "Creating network_analysis directory..."
    mkdir -p /home/ubuntu/network_analysis
fi

# Check for required PCAP files
REQUIRED_FILES=(
    "http_performance.pcap"
    "tcp_issues.pcap"
    "dhcp_failure.pcap"
    "dns_issues.pcap"
    "voip_quality.pcap"
    "unusual_ports.pcap"
    "monitoring_correlation.pcap"
)

cd /home/ubuntu/network_analysis

for file in "${REQUIRED_FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✓ Found: $file"
    else
        echo "✗ Missing: $file - Please wait for system initialization to complete"
    fi
done

# Check for monitoring alerts log
if [ -f "/home/ubuntu/monitoring_alerts.log" ]; then
    echo "✓ Monitoring alerts log present"
else
    echo "✗ Monitoring alerts log missing"
fi

# Verify Wireshark installation
if command -v wireshark &> /dev/null; then
    echo "✓ Wireshark is installed"
else
    echo "✗ Wireshark not found - Please use Desktop connection"
fi

# Verify TShark installation
if command -v tshark &> /dev/null; then
    echo "✓ TShark is installed"
    echo ""
    echo "TShark version:"
    tshark -v | head -n1
else
    echo "✗ TShark not installed"
fi

# Set proper permissions for Wireshark
echo ""
echo "Setting permissions for packet capture..."
sudo setcap cap_net_raw,cap_net_admin+eip /usr/bin/dumpcap 2>/dev/null || true

# Display quick reference
echo ""
echo "Lab Environment Ready!"
echo "====================="
echo ""
echo "Quick Reference Commands:"
echo "  Open Wireshark: wireshark &"
echo "  View TShark examples: ./tshark_examples.sh"
echo "  List PCAP files: ls -la network_analysis/"
echo "  View monitoring alerts: cat monitoring_alerts.log"
echo ""
echo "Remember: Use the Ubuntu Desktop connection for GUI tools!"
echo ""
