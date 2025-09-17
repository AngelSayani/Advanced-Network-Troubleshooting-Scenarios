#!/bin/bash

# Script to generate additional demo captures if needed
# This supplements the real PCAP files downloaded from Wireshark samples

echo "=== Generating supplementary demo captures ==="

cd /home/ubuntu/tshark_analysis

# Create a script to monitor for issues (for demonstration)
cat > monitor_network.sh << 'EOF'
#!/bin/bash
# Network monitoring script for real-time analysis

echo "=== Real-time Network Monitor ==="
echo "Press Ctrl+C to stop monitoring"
echo ""

if [ "$1" == "live" ]; then
    # Live capture mode
    echo "Starting live capture on all interfaces..."
    sudo tshark -i any -f "tcp or udp" -T fields \
        -e frame.time_relative \
        -e ip.src \
        -e ip.dst \
        -e tcp.flags \
        -e tcp.analysis.flags \
        -E header=y | head -100
else
    # File analysis mode
    if [ -z "$1" ]; then
        echo "Usage: $0 <pcap_file> or $0 live"
        exit 1
    fi
    
    echo "Analyzing file: $1"
    echo ""
    
    # Quick stats
    echo "=== Quick Statistics ==="
    TOTAL_PACKETS=$(tshark -r "$1" 2>/dev/null | wc -l)
    echo "Total packets: $TOTAL_PACKETS"
    
    # Protocol distribution
    echo ""
    echo "=== Top Protocols ==="
    tshark -r "$1" -q -z io,phs 2>/dev/null | head -15
    
    # Conversations
    echo ""
    echo "=== Top Conversations ==="
    tshark -r "$1" -q -z conv,tcp 2>/dev/null | head -10
fi
EOF
chmod +x monitor_network.sh

# Create an automated analysis script
cat > auto_analyze.sh << 'EOF'
#!/bin/bash
# Automated PCAP analysis script

PCAP=$1

if [ -z "$PCAP" ]; then
    echo "Usage: $0 <pcap_file>"
    exit 1
fi

if [ ! -f "$PCAP" ]; then
    echo "Error: File $PCAP not found"
    exit 1
fi

echo "==================================="
echo "Automated PCAP Analysis Report"
echo "File: $PCAP"
echo "Date: $(date)"
echo "==================================="
echo ""

# File info
echo "=== File Information ==="
FILE_SIZE=$(ls -lh "$PCAP" | awk '{print $5}')
echo "Size: $FILE_SIZE"
PACKET_COUNT=$(tshark -r "$PCAP" 2>/dev/null | wc -l)
echo "Packets: $PACKET_COUNT"
echo ""

# Time span
echo "=== Capture Duration ==="
START_TIME=$(tshark -r "$PCAP" -T fields -e frame.time_relative -c 1 2>/dev/null)
END_TIME=$(tshark -r "$PCAP" -T fields -e frame.time_relative | tail -1 2>/dev/null)
echo "Duration: $END_TIME seconds"
echo ""

# Top talkers
echo "=== Top Source IPs ==="
tshark -r "$PCAP" -T fields -e ip.src 2>/dev/null | sort | uniq -c | sort -rn | head -5
echo ""

echo "=== Top Destination IPs ==="
tshark -r "$PCAP" -T fields -e ip.dst 2>/dev/null | sort | uniq -c | sort -rn | head -5
echo ""

# Port analysis
echo "=== Top Destination Ports ==="
tshark -r "$PCAP" -T fields -e tcp.dstport 2>/dev/null | sort | uniq -c | sort -rn | head -5
echo ""

# Issues detection
echo "=== Potential Issues ==="
RETRANS=$(tshark -r "$PCAP" -Y "tcp.analysis.retransmission" 2>/dev/null | wc -l)
if [ $RETRANS -gt 0 ]; then
    echo "- TCP Retransmissions detected: $RETRANS packets"
fi

RST_COUNT=$(tshark -r "$PCAP" -Y "tcp.flags.reset==1" 2>/dev/null | wc -l)
if [ $RST_COUNT -gt 0 ]; then
    echo "- TCP Resets detected: $RST_COUNT packets"
fi

DNS_ERRORS=$(tshark -r "$PCAP" -Y "dns.flags.rcode != 0" 2>/dev/null | wc -l)
if [ $DNS_ERRORS -gt 0 ]; then
    echo "- DNS Errors detected: $DNS_ERRORS responses"
fi

ICMP_ERRORS=$(tshark -r "$PCAP" -Y "icmp.type==3 or icmp.type==11" 2>/dev/null | wc -l)
if [ $ICMP_ERRORS -gt 0 ]; then
    echo "- ICMP Errors detected: $ICMP_ERRORS packets"
fi

echo ""
echo "=== Analysis Complete ==="
EOF
chmod +x auto_analyze.sh

# Create TLS analysis script
cat > tls_analyzer.sh << 'EOF'
#!/bin/bash
# TLS/SSL traffic analyzer

PCAP=$1
KEYFILE=$2

echo "=== TLS/SSL Traffic Analysis ==="
echo ""

if [ -z "$PCAP" ]; then
    echo "Usage: $0 <pcap_file> [keylog_file]"
    exit 1
fi

# Basic TLS statistics
echo "=== TLS Handshake Statistics ==="
CLIENT_HELLO=$(tshark -r "$PCAP" -Y "tls.handshake.type==1" 2>/dev/null | wc -l)
SERVER_HELLO=$(tshark -r "$PCAP" -Y "tls.handshake.type==2" 2>/dev/null | wc -l)
CERTIFICATES=$(tshark -r "$PCAP" -Y "tls.handshake.type==11" 2>/dev/null | wc -l)
echo "Client Hello messages: $CLIENT_HELLO"
echo "Server Hello messages: $SERVER_HELLO"
echo "Certificate messages: $CERTIFICATES"
echo ""

# TLS versions
echo "=== TLS Versions in Use ==="
tshark -r "$PCAP" -Y "tls.handshake.version" -T fields -e tls.handshake.version 2>/dev/null | sort | uniq -c | sort -rn
echo ""

# Cipher suites
echo "=== Top Cipher Suites Negotiated ==="
tshark -r "$PCAP" -Y "tls.handshake.ciphersuite" -T fields -e tls.handshake.ciphersuite 2>/dev/null | sort | uniq -c | sort -rn | head -5
echo ""

# SNI analysis
echo "=== Server Name Indication (SNI) ==="
tshark -r "$PCAP" -Y "tls.handshake.extensions_server_name" -T fields -e tls.handshake.extensions_server_name 2>/dev/null | sort | uniq -c | sort -rn | head -10
echo ""

# If keylog file provided, attempt decryption
if [ ! -z "$KEYFILE" ] && [ -f "$KEYFILE" ]; then
    echo "=== Attempting Decryption with Keylog File ==="
    DECRYPTED=$(tshark -r "$PCAP" -o tls.keylog_file:"$KEYFILE" -Y "http or http2" 2>/dev/null | wc -l)
    echo "Decrypted HTTP/HTTP2 frames: $DECRYPTED"
    
    if [ $DECRYPTED -gt 0 ]; then
        echo ""
        echo "=== Sample Decrypted URLs ==="
        tshark -r "$PCAP" -o tls.keylog_file:"$KEYFILE" -Y "http.request.full_uri" -T fields -e http.request.full_uri 2>/dev/null | head -5
    fi
fi

echo ""
echo "=== TLS Analysis Complete ==="
EOF
chmod +x tls_analyzer.sh

# Create performance analysis script
cat > performance_analyzer.sh << 'EOF'
#!/bin/bash
# Network performance analysis script

PCAP=$1

if [ -z "$PCAP" ]; then
    echo "Usage: $0 <pcap_file>"
    exit 1
fi

echo "=== Network Performance Analysis ==="
echo "File: $PCAP"
echo ""

# TCP Analysis
echo "=== TCP Performance Metrics ==="

# RTT Analysis
echo "Round Trip Time Analysis:"
tshark -r "$PCAP" -Y "tcp.analysis.ack_rtt" -T fields -e tcp.analysis.ack_rtt 2>/dev/null | \
    awk '{sum+=$1; count++} END {if(count>0) printf "Average RTT: %.3f ms\n", sum/count*1000}'

# Window scaling
echo ""
echo "TCP Window Scaling:"
WSCALE=$(tshark -r "$PCAP" -Y "tcp.options.wscale.shift" -T fields -e tcp.options.wscale.shift 2>/dev/null | head -1)
if [ ! -z "$WSCALE" ]; then
    echo "Window scale factor: $WSCALE (multiply by 2^$WSCALE)"
else
    echo "No window scaling detected"
fi

# Retransmission analysis
echo ""
echo "=== Retransmission Analysis ==="
TOTAL_TCP=$(tshark -r "$PCAP" -Y "tcp" 2>/dev/null | wc -l)
RETRANS=$(tshark -r "$PCAP" -Y "tcp.analysis.retransmission" 2>/dev/null | wc -l)
FAST_RETRANS=$(tshark -r "$PCAP" -Y "tcp.analysis.fast_retransmission" 2>/dev/null | wc -l)
DUP_ACK=$(tshark -r "$PCAP" -Y "tcp.analysis.duplicate_ack" 2>/dev/null | wc -l)

echo "Total TCP packets: $TOTAL_TCP"
echo "Retransmissions: $RETRANS"
echo "Fast retransmissions: $FAST_RETRANS"
echo "Duplicate ACKs: $DUP_ACK"

if [ $TOTAL_TCP -gt 0 ]; then
    RETRANS_RATE=$(echo "scale=2; $RETRANS * 100 / $TOTAL_TCP" | bc)
    echo "Retransmission rate: $RETRANS_RATE%"
    
    if (( $(echo "$RETRANS_RATE > 2" | bc -l) )); then
        echo "WARNING: High retransmission rate indicates network issues!"
    fi
fi

# HTTP Performance
echo ""
echo "=== HTTP Performance (if applicable) ==="
HTTP_COUNT=$(tshark -r "$PCAP" -Y "http" 2>/dev/null | wc -l)
if [ $HTTP_COUNT -gt 0 ]; then
    echo "HTTP transactions found: $HTTP_COUNT"
    echo ""
    echo "Slowest HTTP responses (>1 second):"
    tshark -r "$PCAP" -Y "http.time > 1" -T fields -e frame.number -e http.request.uri -e http.time 2>/dev/null | head -5
else
    echo "No HTTP traffic found in capture"
fi

echo ""
echo "=== Performance Analysis Complete ==="
EOF
chmod +x performance_analyzer.sh

# Set permissions
chmod +x *.sh
chown ubuntu:ubuntu *.sh

echo "=== Demo capture generation complete ==="
echo "Analysis scripts created:"
ls -la *.sh
