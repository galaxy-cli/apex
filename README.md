# Pro PyQt5 Browser
A lightweight, feature-rich web browser built with Python and PyQt5. This project features a native dark mode, built-in ad-blocking, and an intelligent auto-installer for Linux systems.

## Features

### Auto-Installer: 
Detects missing dependencies and installs them via apt or pip automatically.

### Integrated Ad-Blocker: 
Intercepts network requests to block common ad and tracking domains.

### Dark Theme: 
Custom QSS styling for a modern "Charcoal" desktop aesthetic.

### Smart Navigation:
- Standard Back, Forward, Reload, and Home buttons.
- URL bar defaults to HTTPS for security.
- Automatic Google Search if a search term is entered instead of a URL.

### Progress Tracking: 
Real-time loading bar and status updates.

### Clean Console: 
Silences noisy Chromium and libpng warnings for a cleaner terminal experience.

## Getting Started
PrerequisitesYou only need Python 3 installed. The script is designed to handle the rest.

### Running the Browser
1. Clone or Download the script to your machine.
2. Open your terminal in the script's folder.
3. Run it:
```
python pyqt5-wrapper.py
```
### Note: 
```
On the first run, the script may ask for your sudo password to install the necessary sy# PyQt5 Minimal Web Browser
```
A minimal web browser application built with PyQt5 that includes a URL input bar and automatically installs PyQt5 if it's not already installed.

### Built With
- PyQt5 - The GUI framework.
- QtWebEngine - The Chromium-based browser engine.