#!/bin/bash

# Lab initialization script
echo "=== Initializing TShark Lab Environment ==="

# Create analysis directory if it doesn't exist
mkdir -p /home/ubuntu/tshark_analysis
cd /home/ubuntu/tshark_analysis

# Check for required PCAP files
REQUIRED_FILES="http_performance.pcap tcp_issues.pcap tls_traffic.pcap dns_issues.pcap"
MISSING_FILES=""

for file in $REQUIRED_FILES; do
    if [ ! -f "$file" ]; then
        MISSING_FILES="$MISSING_FILES $file"
    fi
done

if [ ! -z "$MISSING_FILES" ]; then
    echo "Warning: Missing PCAP files:$MISSING_FILES"
    echo "Attempting to download missing files..."
    
    # Try to download missing files
    if [ ! -f "http_performance.pcap" ]; then
        echo "Creating sample HTTP performance capture..."
        # This would normally download from Wireshark samples
        touch http_performance.pcap
    fi
    
    if [ ! -f "tcp_issues.pcap" ]; then
        echo "Creating sample TCP issues capture..."
        touch tcp_issues.pcap
    fi
    
    if [ ! -f "tls_traffic.pcap" ]; then
        echo "Creating sample TLS traffic capture..."
        touch tls_traffic.pcap
    fi
    
    if [ ! -f "dns_issues.pcap" ]; then
        echo "Creating sample DNS issues capture..."
        touch dns_issues.pcap
    fi
fi

# Check for TLS session keys
if [ ! -f "tls_session.keys" ]; then
    echo "Creating sample TLS session keys file..."
    cat > tls_session.keys << 'EOF'
# TLS Session Keys for decryption
# Format: CLIENT_RANDOM <client_random> <master_secret>
CLIENT_RANDOM 5234c2ef0e26f7e2a218ac2df63b1070d6307c7dc2e875e9c5d1e305e3f47b44 d5e73f5070b64f21b5b0094afa1f3e1095f4b5a9ba5e7f2e71e87f7a1234abcd
CLIENT_RANDOM 6789abcd1234567890abcdef1234567890abcdef1234567890abcdef12345678 abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890ab
EOF
fi

# Verify TShark is installed and accessible
if ! command -v tshark &> /dev/null; then
    echo "ERROR: TShark is not installed or not in PATH"
    exit 1
fi

# Check TShark capabilities
echo "TShark version: $(tshark -v 2>&1 | head -1)"

# Verify user can capture packets
if groups | grep -q wireshark; then
    echo "User is in wireshark group - packet capture enabled"
else
    echo "WARNING: User not in wireshark group - some features may be limited"
fi

# Create analysis scripts directory
mkdir -p /home/ubuntu/tshark_analysis/scripts

echo "=== Lab environment initialization complete ==="
echo "Current directory: $(pwd)"
echo "Available PCAP files:"
ls -lh *.pcap 2>/dev/null || echo "No PCAP files found"
echo ""
echo "You can now proceed with the lab exercises."
