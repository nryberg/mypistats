#!/usr/bin/env python3
"""
Simple web server for Pi Stats dashboard.
Serves static files and provides /api/stats endpoint.
"""

import http.server
import json
import os
import socketserver
from urllib.parse import urlparse

PORT = 8181

def get_cpu_usage():
    """Get CPU usage percentage."""
    try:
        with open('/proc/stat', 'r') as f:
            line = f.readline()
        values = line.split()[1:5]
        values = [int(v) for v in values]
        idle = values[3]
        total = sum(values)

        # Store previous values
        if not hasattr(get_cpu_usage, 'prev'):
            get_cpu_usage.prev = (idle, total)
            return 0

        prev_idle, prev_total = get_cpu_usage.prev
        get_cpu_usage.prev = (idle, total)

        idle_delta = idle - prev_idle
        total_delta = total - prev_total

        if total_delta == 0:
            return 0

        return round(100 * (1 - idle_delta / total_delta))
    except:
        return 0

def get_memory_usage():
    """Get memory usage percentage."""
    try:
        with open('/proc/meminfo', 'r') as f:
            lines = f.readlines()

        mem_info = {}
        for line in lines:
            parts = line.split()
            if len(parts) >= 2:
                mem_info[parts[0].rstrip(':')] = int(parts[1])

        total = mem_info.get('MemTotal', 1)
        available = mem_info.get('MemAvailable', 0)
        used_percent = round(100 * (1 - available / total))
        return used_percent
    except:
        return 0

def get_disk_usage():
    """Get disk usage percentage and sizes for root filesystem."""
    try:
        stat = os.statvfs('/')
        total = stat.f_blocks * stat.f_frsize
        free = stat.f_bfree * stat.f_frsize
        used = total - free
        used_percent = round(100 * (1 - free / total))

        # Convert to GB
        total_gb = round(total / (1024**3), 1)
        used_gb = round(used / (1024**3), 1)
        free_gb = round(free / (1024**3), 1)

        return {
            'percent': used_percent,
            'total_gb': total_gb,
            'used_gb': used_gb,
            'free_gb': free_gb
        }
    except:
        return {'percent': 0, 'total_gb': 0, 'used_gb': 0, 'free_gb': 0}

def get_cpu_temp():
    """Get CPU temperature in Celsius."""
    try:
        with open('/sys/class/thermal/thermal_zone0/temp', 'r') as f:
            temp = int(f.read().strip()) / 1000
        return round(temp, 1)
    except:
        return 0

def get_uptime():
    """Get system uptime as human-readable string."""
    try:
        with open('/proc/uptime', 'r') as f:
            uptime_seconds = float(f.read().split()[0])

        days = int(uptime_seconds // 86400)
        hours = int((uptime_seconds % 86400) // 3600)
        minutes = int((uptime_seconds % 3600) // 60)

        if days > 0:
            return f"{days}d {hours}h"
        elif hours > 0:
            return f"{hours}h {minutes}m"
        else:
            return f"{minutes}m"
    except:
        return "--"

def get_load_average():
    """Get 1-minute load average."""
    try:
        with open('/proc/loadavg', 'r') as f:
            load = f.read().split()[0]
        return load
    except:
        return "--"

class StatsHandler(http.server.SimpleHTTPRequestHandler):
    """HTTP handler that serves static files and API endpoints."""

    def do_GET(self):
        parsed = urlparse(self.path)

        if parsed.path == '/api/stats':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()

            disk = get_disk_usage()
            stats = {
                'cpu': get_cpu_usage(),
                'memory': get_memory_usage(),
                'disk': disk['percent'],
                'disk_used': disk['used_gb'],
                'disk_total': disk['total_gb'],
                'disk_free': disk['free_gb'],
                'cpu_temp': get_cpu_temp(),
                'uptime': get_uptime(),
                'load': get_load_average()
            }

            self.wfile.write(json.dumps(stats).encode())
        else:
            # Serve static files
            super().do_GET()

    def log_message(self, format, *args):
        # Suppress logging for cleaner output
        pass

if __name__ == '__main__':
    os.chdir(os.path.dirname(os.path.abspath(__file__)))

    with socketserver.TCPServer(("", PORT), StatsHandler) as httpd:
        print(f"Pi Stats server running at http://localhost:{PORT}")
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print("\nServer stopped.")
