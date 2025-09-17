#!/bin/bash
PCAP=$1
echo "=== TLS Anomaly Detection Report ==="
echo ""
echo "1. Certificate issues:"
tshark -r "$PCAP" -Y "tls.alert_message.level==2" -T fields -e frame.number -e ip.src -e ip.dst -e tls.alert_message.desc 2>/dev/null | head -5
echo ""
echo "2. TLS connections without Server Name Indication (SNI):"
tshark -r "$PCAP" -Y "tls.handshake.type==1 and not tls.handshake.extensions_server_name" -T fields -e frame.number -e ip.dst 2>/dev/null | head -5
echo ""
echo "3. Unusually small TLS record sizes (possible data exfiltration):"
tshark -r "$PCAP" -Y "tls.record.length < 100 and tls.record.content_type==23" -T fields -e frame.number -e ip.src -e ip.dst -e tls.record.length 2>/dev/null | head -10
echo ""
echo "4. TLS session resumption attempts:"
tshark -r "$PCAP" -Y "tls.handshake.session_id_length > 0" -T fields -e frame.number -e ip.src -e ip.dst 2>/dev/null | wc -l
