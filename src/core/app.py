"""
Application initialization and main loop
"""

import sys
from PyQt6.QtGui import QGuiApplication
from PyQt6.QtQml import QQmlApplicationEngine
from PyQt6.QtQuick import QQuickWindow

from src.core.backend import Backend
from src.managers.config_manager import ConfigManager
from src.managers.api_key_manager import APIKeyManager
from src.translators.model_registry import ModelRegistry
from src.utils.resource_path import get_resource_path


def main():
    """Main entry point for the application"""
    QQuickWindow.setSceneGraphBackend('software')
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    # Initialize managers
    config_mgr = ConfigManager()
    config = config_mgr.load_config()
    api_key_mgr = APIKeyManager()

    # Load QML
    engine.quit.connect(app.quit)
    qml_file = get_resource_path('UI/Main.qml')
    print(f"Loading QML from: {qml_file}")
    engine.load(qml_file)

    if engine.rootObjects():
        root = engine.rootObjects()[0]
        
        # Set saved config values
        root.setProperty('w', config['window_width'])
        root.setProperty('h', config['window_height'])
        root.setProperty('o', config['window_opacity'])
        root.setProperty('textColor', config['text_color'])
        root.setProperty('textSize', config['text_size'])
        root.setProperty('textFont', config['text_font'])
        root.setProperty('llmPrompt', config['prompt'])
        root.setProperty('selectedModel', config['selected_model'])
        root.setProperty('availableModels', ModelRegistry.get_model_names())
        
        # Set backend
        back_end = Backend(config_mgr, api_key_mgr)
        root.setProperty('backend', back_end)
        back_end.bootUp()
        
        return app.exec()
    else:
        print("Failed to load QML")
        return -1