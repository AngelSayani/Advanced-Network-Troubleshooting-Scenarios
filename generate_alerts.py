#!/usr/bin/env python3

"""
Generate simulated monitoring alerts for correlation with packet analysis
This script creates realistic monitoring alerts that align with network issues
"""

import random
from datetime import datetime, timedelta

def generate_alerts():
    """Generate various types of monitoring alerts"""
    
    base_time = datetime.now() - timedelta(hours=1)
    alerts = []
    
    # Network performance alerts
    alerts.append({
        'time': base_time + timedelta(minutes=5),
        'source': 'NETFLOW',
        'severity': 'WARNING',
        'message': 'High bandwidth utilization detected on interface eth0 (85%)'
    })
    
    alerts.append({
        'time': base_time + timedelta(minutes=7),
        'source': 'SNMP',
        'severity': 'CRITICAL',
        'message': 'CPU usage critical on web-server-01 (92%)'
    })
    
    # Application performance alerts
    alerts.append({
        'time': base_time + timedelta(minutes=8),
        'source': 'APM',
        'severity': 'WARNING',
        'message': 'Response time threshold exceeded for /api/getData (2.5s)'
    })
    
    alerts.append({
        'time': base_time + timedelta(minutes=10),
        'source': 'APM',
        'severity': 'WARNING',
        'message': 'Database connection pool exhausted'
    })
    
    # TCP/Network issues
    alerts.append({
        'time': base_time + timedelta(minutes=12),
        'source': 'SYSLOG',
        'severity': 'WARNING',
        'message': 'Multiple connection resets from 192.168.1.100'
    })
    
    alerts.append({
        'time': base_time + timedelta(minutes=15),
        'source': 'TCP_MONITOR',
        'severity': 'WARNING',
        'message': 'Excessive retransmissions detected (>2%)'
    })
    
    # Security alerts
    alerts.append({
        'time': base_time + timedelta(minutes=18),
        'source': 'IDS',
        'severity': 'HIGH',
        'message': 'Suspicious activity on port 31337'
    })
    
    alerts.append({
        'time': base_time + timedelta(minutes=20),
        'source': 'FIREWALL',
        'severity': 'INFO',
        'message': 'Unusual outbound connections to port 8888'
    })
    
    # Protocol-specific alerts
    alerts.append({
        'time': base_time + timedelta(minutes=22),
        'source': 'DNS',
        'severity': 'WARNING',
        'message': 'Query failures increasing - 15% NXDOMAIN responses'
    })
    
    alerts.append({
        'time': base_time + timedelta(minutes=25),
        'source': 'DHCP',
        'severity': 'WARNING',
        'message': 'Pool exhaustion warning - 95% addresses allocated'
    })
    
    alerts.append({
        'time': base_time + timedelta(minutes=28),
        'source': 'VOIP',
        'severity': 'WARNING',
        'message': 'Call quality degradation - MOS below 3.5'
    })
    
    # DDoS/Attack patterns
    alerts.append({
        'time': base_time + timedelta(minutes=30),
        'source': 'NETFLOW',
        'severity': 'CRITICAL',
        'message': 'Unusual traffic pattern detected - possible DDoS'
    })
    
    alerts.append({
        'time': base_time + timedelta(minutes=32),
        'source': 'IPS',
        'severity': 'HIGH',
        'message': 'SYN flood detected from multiple sources'
    })
    
    # Service degradation
    alerts.append({
        'time': base_time + timedelta(minutes=35),
        'source': 'SERVICE_MONITOR',
        'severity': 'WARNING',
        'message': 'Web service response degradation - 500 errors increasing'
    })
    
    alerts.append({
        'time': base_time + timedelta(minutes=38),
        'source': 'LOAD_BALANCER',
        'severity': 'INFO',
        'message': 'Backend server removed from pool - health check failed'
    })
    
    return sorted(alerts, key=lambda x: x['time'])

def format_alert(alert):
    """Format alert for output"""
    timestamp = alert['time'].strftime('%Y-%m-%d %H:%M:%S')
    return f"{timestamp} [{alert['source']}] {alert['severity']}: {alert['message']}"

def main():
    """Generate and display monitoring alerts"""
    print("MONITORING SYSTEM ALERTS")
    print("=" * 80)
    print("Generated alerts for correlation with packet analysis")
    print("=" * 80)
    print()
    
    alerts = generate_alerts()
    
    for alert in alerts:
        print(format_alert(alert))
    
    print()
    print("=" * 80)
    print(f"Total alerts generated: {len(alerts)}")
    print("Use these timestamps to correlate with Wireshark packet captures")
    print("=" * 80)

if __name__ == "__main__":
    main()
