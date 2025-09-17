#!/bin/bash
PCAP=$1
echo "=== Protocol Troubleshooting Report ==="
echo "File: $PCAP"
echo ""
echo "=== Protocol Distribution ==="
tshark -r "$PCAP" -q -z io,phs 2>/dev/null | head -20
echo ""
echo "=== DNS Analysis ==="
DNS_QUERIES=$(tshark -r "$PCAP" -Y "dns.flags.response==0" 2>/dev/null | wc -l)
DNS_RESPONSES=$(tshark -r "$PCAP" -Y "dns.flags.response==1" 2>/dev/null | wc -l)
DNS_ERRORS=$(tshark -r "$PCAP" -Y "dns.flags.rcode > 0" 2>/dev/null | wc -l)
echo "Queries: $DNS_QUERIES, Responses: $DNS_RESPONSES, Errors: $DNS_ERRORS"
if [ $DNS_QUERIES -gt 0 ]; then
    SUCCESS_RATE=$(echo "scale=2; ($DNS_RESPONSES - $DNS_ERRORS) * 100 / $DNS_QUERIES" | bc)
    echo "DNS Success Rate: $SUCCESS_RATE%"
fi
echo ""
echo "=== TLS Handshake Analysis ==="
TLS_HELLOS=$(tshark -r "$PCAP" -Y "tls.handshake.type==1" 2>/dev/null | wc -l)
TLS_COMPLETE=$(tshark -r "$PCAP" -Y "tls.handshake.type==20" 2>/dev/null | wc -l)
echo "Client Hellos: $TLS_HELLOS, Completed Handshakes: $TLS_COMPLETE"
if [ $TLS_HELLOS -gt 0 ] && [ $TLS_COMPLETE -lt $TLS_HELLOS ]; then
    echo "WARNING: Incomplete TLS handshakes detected!"
fi
