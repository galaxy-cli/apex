#!/usr/bin/env python3
import sys
import os
import subprocess
import importlib.util
import urllib.parse
import signal  # Added for CTRL+C handling

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
                             QAction, QStyle, QProgressBar, QStatusBar, 
                             QTabWidget, QFileDialog)
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
        self.resize(1200, 800)
        
        # CHANGED: Updated homepage to DuckDuckGo
        self.home_url = "https://duckduckgo.com"

        # Interceptor for Ad-Blocking
        self.interceptor = AdBlocker()

        # Tabbed Engine Setup
        self.tabs = QTabWidget()
        self.tabs.setDocumentMode(True)
        self.tabs.setTabsClosable(True)
        self.tabs.tabCloseRequested.connect(self.close_tab)
        self.tabs.currentChanged.connect(self.tab_changed)
        self.setCentralWidget(self.tabs)

        # UI Elements
        self.status = QStatusBar()
        self.setStatusBar(self.status)
        self.progress = QProgressBar()
        self.progress.setMaximumWidth(200)
        self.status.addPermanentWidget(self.progress)

        navtb = QToolBar("Navigation")
        self.addToolBar(navtb)

        # Buttons
        self.add_btn(navtb, QStyle.SP_ArrowBack, "Back", self.handle_back)
        self.add_btn(navtb, QStyle.SP_ArrowForward, "Forward", self.handle_forward)
        self.add_btn(navtb, QStyle.SP_BrowserReload, "Reload", self.handle_reload)
        self.add_btn(navtb, QStyle.SP_DirHomeIcon, "Home", self.go_home)
        self.add_btn(navtb, QStyle.SP_FileDialogNewFolder, "New Tab", self.handle_new_tab_btn)

        self.url_bar = QLineEdit()
        self.url_bar.returnPressed.connect(self.navigate)
        self.url_bar.mousePressEvent = self.handle_url_focus
        navtb.addWidget(self.url_bar)

        self.apply_theme()
        
        # Open Initial Tab
        self.add_new_tab(QUrl(self.home_url), "Homepage")

    def add_btn(self, tb, icon, label, slot):
        btn = QAction(self.style().standardIcon(icon), label, self)
        btn.triggered.connect(slot)
        tb.addAction(btn)

    def current_browser(self):
        return self.tabs.currentWidget()

    def handle_back(self):
        if self.current_browser(): self.current_browser().back()

    def handle_forward(self):
        if self.current_browser(): self.current_browser().forward()

    def handle_reload(self):
        if self.current_browser(): self.current_browser().reload()

    def handle_new_tab_btn(self):
        self.add_new_tab(QUrl(self.home_url), "New Tab")

    def handle_url_focus(self, event):
        self.url_bar.selectAll()

    def add_new_tab(self, qurl=None, label="New Tab"):
        browser = QWebEngineView()
        browser.page().profile().setUrlRequestInterceptor(self.interceptor)
        browser.page().profile().downloadRequested.connect(self.handle_download)

        index = self.tabs.addTab(browser, label)
        self.tabs.setCurrentIndex(index)

        # Cleaner Signal Routing
        browser.loadProgress.connect(lambda val: self.on_load_progress(browser, val))
        browser.urlChanged.connect(lambda url: self.on_url_changed(browser, url))
        browser.titleChanged.connect(lambda title: self.on_title_changed(browser, title))

        if qurl:
            browser.setUrl(qurl)

    def on_load_progress(self, browser, val):
        if browser == self.current_browser():
            self.progress.setValue(val)

    def on_url_changed(self, browser, url):
        if browser == self.current_browser():
            self.url_bar.setText(url.toString())

    def on_title_changed(self, browser, title):
        index = self.tabs.indexOf(browser)
        if index != -1:
            short_title = title[:15] + "..." if len(title) > 15 else title
            self.tabs.setTabText(index, short_title)
            if browser == self.current_browser():
                self.setWindowTitle(f"{title} - Pro Browser")

    def close_tab(self, index):
        if self.tabs.count() > 1:
            self.tabs.removeTab(index)
        else:
            self.close()

    def tab_changed(self, index):
        browser = self.tabs.widget(index)
        if browser:
            self.url_bar.setText(browser.url().toString())
            self.setWindowTitle(f"{browser.title()} - Pro Browser")

    def go_home(self): 
        if self.current_browser():
            self.current_browser().setUrl(QUrl(self.home_url))

    def navigate(self):
        text = self.url_bar.text().strip()
        if not text or not self.current_browser():
            return
        
        if text.startswith("/") or text.startswith("localhost") or text.startswith("127.0.0.1"):
            url = f"http://{text}" if not text.startswith("/") else f"file://{text}"
        # CHANGED: Updated the fallback search string to use DuckDuckGo
        elif "." not in text or " " in text:
            url = f"https://duckduckgo.com{urllib.parse.quote(text)}"
        else:
            url = text if text.startswith("http") else f"https://{text}"

        self.current_browser().setUrl(QUrl(url))

    def handle_download(self, download_item):
        path, _ = QFileDialog.getSaveFileName(self, "Save File", download_item.suggestedFileName())
        if path:
            download_item.setPath(path)
            download_item.accept()
            self.status.showMessage(f"Downloading: {download_item.suggestedFileName()}", 5000)

    def apply_theme(self):
        self.setStyleSheet("""
            QMainWindow, QToolBar { background-color: #2b2b2b; color: white; border: none; }
            QLineEdit { background-color: #3c3f41; color: white; padding: 5px; border-radius: 3px; border: 1px solid #555; }
            QProgressBar { border: 1px solid grey; border-radius: 5px; text-align: center; }
            QProgressBar::chunk { background-color: #05B8CC; }
            QTabBar::tab { background: #3c3f41; color: #bbb; padding: 8px 20px; border: 1px solid #2b2b2b; }
            QTabBar::tab:selected { background: #2b2b2b; color: white; border-bottom: 2px solid #05B8CC; }
            QTabWidget::pane { border: none; }
        """)

if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    
    app = QApplication(sys.argv)
    window = ProBrowser()
    window.show()
    sys.exit(app.exec_())