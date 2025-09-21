#!/bin/bash

# Backup script to download PCAP files if main setup fails

PCAP_DIR="/home/ubuntu/lab_files/pcaps"
mkdir -p $PCAP_DIR

echo "Downloading PCAP files for lab scenarios..."

# Function to download and extract if needed
download_pcap() {
    local url=$1
    local output=$2
    local description=$3
    
    echo "Downloading: $description"
    if wget -q -O "$output" "$url"; then
        # Check if file is gzipped and extract if needed
        if file "$output" | grep -q "gzip compressed"; then
            mv "$output" "$output.gz"
            gunzip -f "$output.gz" 2>/dev/null || true
        fi
        echo "✓ Downloaded: $description"
    else
        echo "✗ Failed to download: $description"
    fi
}

# Performance and latency issues - HTTP captures with delays
download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/http2-16-ssl.pcapng" \
    "$PCAP_DIR/http_performance.pcap" \
    "HTTP/2 performance capture"

# TCP issues including resets
download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/tcp-ecn-sample.pcap.gz" \
    "$PCAP_DIR/tcp_analysis.pcap" \
    "TCP with ECN and potential issues"

# DHCP capture
download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dhcp.pcap" \
    "$PCAP_DIR/dhcp_capture.pcap" \
    "DHCP transaction capture"

# DNS capture with various queries
download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dns.cap" \
    "$PCAP_DIR/dns_capture.pcap" \
    "DNS queries and responses"

# VoIP/SIP capture
download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/sip-rtp.pcap" \
    "$PCAP_DIR/voip_sip_rtp.pcap" \
    "SIP and RTP VoIP traffic"

# Additional NetResec captures for variety
download_pcap \
    "https://www.netresec.com/files/pcap/smtp.pcap" \
    "$PCAP_DIR/smtp_traffic.pcap" \
    "SMTP email traffic"

download_pcap \
    "https://www.netresec.com/files/pcap/ftp-example.pcap" \
    "$PCAP_DIR/ftp_traffic.pcap" \
    "FTP transfer with potential issues"

# HTTP with potential performance issues from NetResec
download_pcap \
    "https://www.netresec.com/files/pcap/http.pcap" \
    "$PCAP_DIR/http_netresec.pcap" \
    "HTTP traffic from NetResec"

# Create combined capture for comprehensive analysis
echo "Creating combined capture files..."

# Check if we have necessary files and create symbolic links for expected names
if [ -f "$PCAP_DIR/http_performance.pcap" ]; then
    ln -sf "$PCAP_DIR/http_performance.pcap" "$PCAP_DIR/performance_issue.pcap"
fi

if [ -f "$PCAP_DIR/ftp_traffic.pcap" ]; then
    ln -sf "$PCAP_DIR/ftp_traffic.pcap" "$PCAP_DIR/tcp_resets.pcap"
fi

if [ -f "$PCAP_DIR/dhcp_capture.pcap" ] && [ -f "$PCAP_DIR/dns_capture.pcap" ]; then
    # Merge DHCP and DNS if both exist
    if command -v mergecap >/dev/null 2>&1; then
        mergecap -w "$PCAP_DIR/dhcp_dns_issues.pcap" \
            "$PCAP_DIR/dhcp_capture.pcap" \
            "$PCAP_DIR/dns_capture.pcap" 2>/dev/null || \
            ln -sf "$PCAP_DIR/dhcp_capture.pcap" "$PCAP_DIR/dhcp_dns_issues.pcap"
    else
        ln -sf "$PCAP_DIR/dhcp_capture.pcap" "$PCAP_DIR/dhcp_dns_issues.pcap"
    fi
fi

if [ -f "$PCAP_DIR/voip_sip_rtp.pcap" ]; then
    ln -sf "$PCAP_DIR/voip_sip_rtp.pcap" "$PCAP_DIR/voip_quality.pcap"
fi

if [ -f "$PCAP_DIR/smtp_traffic.pcap" ]; then
    ln -sf "$PCAP_DIR/smtp_traffic.pcap" "$PCAP_DIR/non_standard_ports.pcap"
fi

# Set permissions
chown -R ubuntu:ubuntu $PCAP_DIR

echo "PCAP download complete!"
echo "Files available in: $PCAP_DIR"
ls -la $PCAP_DIR/*.pcap 2>/dev/null | head -10
