# Framboise Stats

A Raspberry Pi dashboard application designed for kiosk-style display on a 7" touchscreen. Displays time, weather, system statistics, and more in a clean, modern interface.

## Features

- **Auto-refresh**: Page refreshes every 60 seconds while preserving the active tab
- **Idle dimmer**: Screen dims after 10 minutes of inactivity, showing a subtle clock
- **Responsive design**: Optimized for 7" Raspberry Pi displays
- **Touch-friendly**: Large buttons and readable text for touchscreen interaction

## Tabs

### Now
The main dashboard view displaying:
- Current time and date
- Current weather conditions with icon
- Current temperature
- 4-hour forecast showing upcoming temperatures

### Server
System statistics for the Raspberry Pi:
- CPU usage percentage
- Memory usage percentage
- Disk usage with used/total GB
- CPU temperature
- System uptime
- Load average

### Forecast
6-day weather forecast (today + 5 days) with a unique visual representation:
- Each card's **vertical position** is determined by its high temperature (highest high at top of screen)
- Each card's **height** represents the temperature range between its high and low
- The top edge of each card aligns with its high temp, the bottom edge with its low temp
- Creates a visual "bar chart" showing both absolute temperatures and daily ranges across the week

### Time To
A visual countdown to the next half-hour mark:
- Circular pie chart showing remaining minutes
- Displays target time (e.g., "until 2:30 PM")
- Useful for time-boxed activities or meeting schedules

### Saver
An animated screensaver featuring:
- Colorful glowing orbs that float and bounce
- Subtle pulsing effects
- Dark background to reduce screen burn-in

### Notes
An embedded iframe for displaying external content:
- Currently configured to load a Tailscale-accessible notes page
- Can be customized to display any web content

## Technical Details

### Architecture
- **Frontend**: Single-page HTML/CSS/JavaScript application (`index.html`)
- **Backend**: Python HTTP server (`server.py`) on port 8181
- **Weather API**: Open-Meteo (free, no API key required)
- **Location**: Configured for Minneapolis, MN (44.98, -93.27)

### API Endpoints
- `GET /` - Serves the dashboard
- `GET /api/stats` - Returns JSON with system statistics:
  ```json
  {
    "cpu": 15,
    "memory": 42,
    "disk": 67,
    "disk_used": 12.5,
    "disk_total": 32.0,
    "cpu_temp": 45,
    "uptime": "5d 3h",
    "load": "0.52"
  }
  ```

### Deployment
Use the included `deploy.sh` script to deploy to a Raspberry Pi:
```bash
./deploy.sh
```

This script:
1. Copies files to the Pi via SSH
2. Sets up a systemd service for auto-start
3. Configures Chromium to launch in kiosk mode

## Configuration

### Weather Location
To change the location, edit the latitude and longitude in `index.html`:
```javascript
const lat = 44.98, lon = -93.27;  // Minneapolis, MN
```

### Notes URL
To change the embedded notes page, edit the iframe src:
```html
<iframe id="notes-iframe" src="https://your-url-here/"></iframe>
```

### Idle Timeout
To adjust the screensaver timeout, modify the constant in `index.html`:
```javascript
const IDLE_TIMEOUT = 10 * 60 * 1000; // 10 minutes
```

## Requirements

- Raspberry Pi (tested on Pi 4)
- Python 3.x
- Chromium browser (for kiosk mode)
- Network connection (for weather data)

## License

MIT
