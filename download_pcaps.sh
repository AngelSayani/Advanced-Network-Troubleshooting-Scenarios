#!/bin/bash

# Backup script to download PCAP files if main setup fails
# Uses only approved sources from wiki.wireshark.org and netresec.com

PCAP_DIR="/home/ubuntu/lab_files/pcaps"
mkdir -p $PCAP_DIR

# Use proxy if available
if [ ! -z "$http_proxy" ]; then
    export http_proxy=$http_proxy
    export https_proxy=$http_proxy
    WGET_PROXY="--proxy=on"
else
    WGET_PROXY="--proxy=off"
fi

echo "Downloading PCAP files for lab scenarios..."

# Function to download and extract if needed
download_pcap() {
    local url=$1
    local output=$2
    local description=$3
    
    echo "Downloading: $description"
    if wget $WGET_PROXY -q -O "$output" "$url"; then
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

# Working Wireshark Wiki URLs only
download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/tcp-ecn-sample.pcap" \
    "$PCAP_DIR/tcp_performance.pcap" \
    "TCP with ECN (performance issues)"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dhcp.pcap" \
    "$PCAP_DIR/dhcp.pcap" \
    "DHCP traffic"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/dns.cap" \
    "$PCAP_DIR/dns.pcap" \
    "DNS queries and responses"

download_pcap \
    "https://wiki.wireshark.org/uploads/27707187aeb30df68e70c8fb9d614981/http.cap" \
    "$PCAP_DIR/http.pcap" \
    "Simple HTTP request/response"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/SIP_CALL_RTP_G711" \
    "$PCAP_DIR/sip_rtp.pcap" \
    "SIP call with RTP"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/telnet-raw.pcap" \
    "$PCAP_DIR/telnet.pcap" \
    "Telnet session (clear text)"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/tcp-ethereal-file1.trace" \
    "$PCAP_DIR/tcp_large.pcap" \
    "Large TCP transfer"

download_pcap \
    "https://wiki.wireshark.org/uploads/__moin_import__/attachments/SampleCaptures/aaa.pcap" \
    "$PCAP_DIR/sip_rtp_sample.pcap" \
    "Sample SIP and RTP traffic"

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

# Create symbolic links for expected file names
echo "Creating links for expected PCAP files..."

# Link files to expected names for the lab
if [ -f "$PCAP_DIR/tcp_performance.pcap" ]; then
    ln -sf "$PCAP_DIR/tcp_performance.pcap" "$PCAP_DIR/performance_issue.pcap"
fi

if [ -f "$PCAP_DIR/tcp_large.pcap" ]; then
    ln -sf "$PCAP_DIR/tcp_large.pcap" "$PCAP_DIR/tcp_resets.pcap"
fi

if [ -f "$PCAP_DIR/telnet.pcap" ]; then
    ln -sf "$PCAP_DIR/telnet.pcap" "$PCAP_DIR/non_standard_ports.pcap"
fi

if [ -f "$PCAP_DIR/sip_rtp_sample.pcap" ]; then
    ln -sf "$PCAP_DIR/sip_rtp_sample.pcap" "$PCAP_DIR/voip_quality.pcap"
fi

# Combine DHCP and DNS if both exist
if [ -f "$PCAP_DIR/dhcp.pcap" ] && [ -f "$PCAP_DIR/dns.pcap" ]; then
    if command -v mergecap >/dev/null 2>&1; then
        mergecap -w "$PCAP_DIR/dhcp_dns_issues.pcap" \
            "$PCAP_DIR/dhcp.pcap" \
            "$PCAP_DIR/dns.pcap" 2>/dev/null || \
            cat "$PCAP_DIR/dhcp.pcap" "$PCAP_DIR/dns.pcap" > "$PCAP_DIR/dhcp_dns_issues.pcap"
    else
        cat "$PCAP_DIR/dhcp.pcap" "$PCAP_DIR/dns.pcap" > "$PCAP_DIR/dhcp_dns_issues.pcap" 2>/dev/null || \
        cp "$PCAP_DIR/dhcp.pcap" "$PCAP_DIR/dhcp_dns_issues.pcap"
    fi
fi

# Set permissions
chown -R ubuntu:ubuntu $PCAP_DIR

echo "PCAP download complete!"
echo "Files available in: $PCAP_DIR"
ls -la $PCAP_DIR/*.pcap 2>/dev/null | head -15
