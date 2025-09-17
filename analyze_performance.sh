#!/bin/bash
PCAP=$1
echo "=== Network Performance Analysis Report ==="
echo "File: $PCAP"
echo "Analysis Date: $(date)"
echo ""
echo "=== HTTP Performance Metrics ==="
echo "Requests with response time > 1 second:"
tshark -r "$PCAP" -Y "http.time > 1" -T fields -e frame.number -e http.request.uri -e http.time 2>/dev/null | head -5
echo ""
echo "=== TCP Health Indicators ==="
TOTAL=$(tshark -r "$PCAP" -Y "tcp" 2>/dev/null | wc -l)
RETRANS=$(tshark -r "$PCAP" -Y "tcp.analysis.retransmission" 2>/dev/null | wc -l)
if [ $TOTAL -gt 0 ]; then
    PERCENT=$(echo "scale=2; $RETRANS * 100 / $TOTAL" | bc)
    echo "Retransmission rate: $PERCENT%"
    if (( $(echo "$PERCENT > 2" | bc -l) )); then
        echo "WARNING: High retransmission rate detected!"
    fi
fi
echo ""
echo "=== Top Talkers by Packet Count ==="
tshark -r "$PCAP" -T fields -e ip.src 2>/dev/null | sort | uniq -c | sort -rn | head -5
