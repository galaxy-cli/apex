import sys
import os
import subprocess
import importlib.util

# 1. SILENCE WARNINGS (libpng and JS deprecation)
os.environ["QTWEBENGINE_CHROMIUM_FLAGS"] = "--disable-logging"

# 2. AUTO-INSTALLER
def install_and_import(module_name, pip_name=None, apt_name=None):
    if importlib.util.find_spec(module_name) is not None:
        return
    print(f"[*] Setting up {module_name}...")
    if apt_name:
        try:
            subprocess.check_call(["sudo", "apt", "update"])
            subprocess.check_call(["sudo", "apt", "install", "-y", apt_name])
            if importlib.util.find_spec(module_name) is not None: return
        except: pass
    subprocess.check_call([sys.executable, "-m", "pip", "install", 
                          pip_name or module_name, "--break-system-packages"])

install_and_import("PyQt5", apt_name="python3-pyqt5")
install_and_import("PyQt5.QtWebEngineWidgets", pip_name="PyQt5-QtWebEngine", apt_name="python3-pyqt5.qtwebengine")

from PyQt5.QtWidgets import (QApplication, QMainWindow, QToolBar, QLineEdit, 
                             QAction, QStyle, QProgressBar, QStatusBar)
from PyQt5.QtCore import QUrl
from PyQt5.QtWebEngineWidgets import QWebEngineView
from PyQt5.QtWebEngineCore import QWebEngineUrlRequestInterceptor

# 3. AD-BLOCKER
class AdBlocker(QWebEngineUrlRequestInterceptor):
    def __init__(self):
        super().__init__()
        self.block_list = ["googleads", "doubleclick", "adservice", "analytics"]

    def interceptRequest(self, info):
        url = info.requestUrl().toString()
        if any(ad in url for ad in self.block_list):
            info.block(True)

class ProBrowser(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("Pro Browser")
        self.resize(1100, 800)
        self.home_url = "https://www.google.com"

        # Browser Setup
        self.browser = QWebEngineView()
        self.interceptor = AdBlocker()
        self.browser.page().profile().setUrlRequestInterceptor(self.interceptor)
        self.setCentralWidget(self.browser)

        # UI Elements
        self.status = QStatusBar()
        self.setStatusBar(self.status)
        self.progress = QProgressBar()
        self.progress.setMaximumWidth(200)
        self.status.addPermanentWidget(self.progress)

        navtb = QToolBar("Navigation")
        self.addToolBar(navtb)

        # Buttons
        self.add_btn(navtb, QStyle.SP_ArrowBack, "Back", self.browser.back)
        self.add_btn(navtb, QStyle.SP_ArrowForward, "Forward", self.browser.forward)
        self.add_btn(navtb, QStyle.SP_BrowserReload, "Reload", self.browser.reload)
        self.add_btn(navtb, QStyle.SP_DirHomeIcon, "Home", self.go_home)

        self.url_bar = QLineEdit()
        self.url_bar.returnPressed.connect(self.navigate)
        self.url_bar.mousePressEvent = lambda e: self.url_bar.selectAll()
        navtb.addWidget(self.url_bar)

        # Sync
        self.browser.loadProgress.connect(self.progress.setValue)
        self.browser.urlChanged.connect(lambda u: self.url_bar.setText(u.toString()))
        self.browser.titleChanged.connect(lambda t: self.setWindowTitle(f"{t} - Pro Browser"))

        self.apply_theme()
        self.go_home()

    def add_btn(self, tb, icon, label, slot):
        btn = QAction(self.style().standardIcon(icon), label, self)
        btn.triggered.connect(slot)
        tb.addAction(btn)

    def go_home(self): self.browser.setUrl(QUrl(self.home_url))

    def apply_theme(self):
        self.setStyleSheet("""
            QMainWindow, QToolBar { background-color: #2b2b2b; color: white; border: none; }
            QLineEdit { background-color: #3c3f41; color: white; padding: 5px; border-radius: 3px; }
            QProgressBar { border: 1px solid grey; border-radius: 5px; text-align: center; }
            QProgressBar::chunk { background-color: #05B8CC; }
        """)

    def navigate(self):
        text = self.url_bar.text().strip()
        url = text if "." in text else f"https://google.com{text}"
        if not url.startswith("http"): url = "https://" + url
        self.browser.setUrl(QUrl(url))

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = ProBrowser()
    window.show()
    sys.exit(app.exec_())