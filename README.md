# apex

A minimalist, high-performance, dark-themed web browser built with Python and PyQt5. Designed to be lightweight, secure, and fast.

## Features

*   **Multi-Tabbed Browsing:** Smooth tab management with auto-adjusting title lengths and integrated progress tracking.
*   **Network-Level Ad Blocker:** Intercepts and blocks tracking engines, doubleclick, and analytics requests at the connection layer.
*   **Smart Omnibox Routing:** Automatically detects local file paths (`/home/user/...`), local hosts (`localhost`, `127.0.0.1`), and search requests via Google.
*   **Native File Downloads:** Integrates directly with your system's native file dialog for clean down-saving.
*   **Automated Dependency Handling:** Auto-detects and provisions system-level `apt` dependencies and Python packagers upon launch.
*   **Modern Visual Interface:** Dark layout designed for reduced eye strain with accent-colored visual indicators.

## Installation

### 1. Make the Script Executable
Ensure the file has execution permissions on your Linux system:
```bash
chmod +x apex
```

### 2. Move to Path (Optional)
To launch the browser from any terminal location without the path directory, move it to your local binary folder:
```bash
mv apex ~/.local/bin/apex
```

## Usage

Launch the browser directly from your terminal console:
```bash
apex
```

*   **To Search:** Type keywords into the address bar and press **Enter** to search Google.
*   **To Visit a URL:** Type a domain name (e.g., `github.com`) into the address bar.
*   **To Clear/Select Input:** Single-click the address bar to auto-select the entire path for fast typing.

## Requirements

The script automatically detects and installs missing assets, but relies on:
*   Python 3.x
*   PyQt5 & PyQt5-QtWebEngine
