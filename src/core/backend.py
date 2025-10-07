"""
Backend class handling translation logic and Qt signal/slot communication
"""

import re
import textwrap
import threading
import subprocess
from PyQt6.QtCore import QObject, pyqtSignal, pyqtSlot, QVariant
from PyQt6.QtGui import QGuiApplication
import pyperclip

from src.translators.model_registry import ModelRegistry


class Backend(QObject):
    def __init__(self, config_manager, api_key_manager):
        QObject.__init__(self)
        self.config_manager = config_manager
        self.api_key_manager = api_key_manager
        self.translator = None
        self.translator_lock = threading.Lock()
        self.running = False
        
    # Signals
    translatedText = pyqtSignal(str)
    notificationRequested = pyqtSignal(str, str)

    def split_japanese_english(self, text):
        """Split text into Japanese and English parts"""
        text = text.replace("\r\n", "\n").strip()
        
        # Case 1: split by blank line
        if "\n\n" in text:
            parts = text.split("\n\n", 1)
            return parts[0].strip(), parts[1].strip()
        
        # Case 2: no blank line → detect first English letter
        match = re.search(r'[A-Za-z]', text)
        if match:
            idx = match.start()
            return text[:idx].strip(), text[idx:].strip()
        
        # Default: treat as only Japanese
        return text.strip(), ""

    def wrap_text(self, text, width=50):
        """Wrap text to specified width"""
        if len(text) <= width:
            return [text]
        return textwrap.wrap(text, width=width)

    def format_japanese_english(self, text, width=50):
        """Format Japanese and English text with wrapping"""
        jap, eng = self.split_japanese_english(text)
        jap_lines = self.wrap_text(jap, width)
        eng_lines = self.wrap_text(eng, width)
        return "\n".join(jap_lines) + "\n\n" + "\n".join(eng_lines)
    
    def updater(self, translated_text):
        """Emit translated text signal"""
        self.translatedText.emit(translated_text)
    
    def show_notification(self, message, notification_type="success"):
        """Emit notification signal"""
        print(f"[DEBUG] Emitting notification: {message} ({notification_type})")
        self.notificationRequested.emit(message, notification_type)
    
    def get_clipboard_text(self):
        """Get text from clipboard using PowerShell"""
        return subprocess.getoutput("powershell.exe -Command Get-Clipboard")
    
    def reinitialize_translator(self):
        """Reinitialize the translator with current config"""
        config = self.config_manager.load_config()
        role = config.get('prompt', '')
        selected_model = config.get('selected_model', 'Gemini')
        
        # Get API key for selected model
        api_key_name = ModelRegistry.get_api_key_name(selected_model)
        api_key = self.api_key_manager.get_active_key(api_key_name) if api_key_name else None
        
        with self.translator_lock:
            try:
                self.translator = ModelRegistry.create_translator(selected_model, role, api_key)
                print(f"Reinitialized {selected_model} translator")
                return True
            except Exception as e:
                print(f"Error reinitializing translator: {e}")
                self.translator = None
                return False
        
    def bootUp(self):
        """Start the translation loop in a separate thread"""
        if self.running:
            print("Translation loop already running")
            return
            
        self.running = True
        t_thread = threading.Thread(target=self._bootUp)
        t_thread.daemon = True
        t_thread.start()
        
    def _bootUp(self):
        """Main translation loop"""
        self.reinitialize_translator()
        last_sentence = ""
        pyperclip.copy("")  # Empty clipboard when application starts
    
        while self.running:
            clipboard_text = self.get_clipboard_text()                
            
            # Skip if clipboard text is empty or same as last
            if clipboard_text == last_sentence or clipboard_text == "":
                continue              
            else:
                last_sentence = clipboard_text
                
                with self.translator_lock:
                    if self.translator:
                        new_translated_text = self.translator.translate_text(clipboard_text)
                    else:
                        new_translated_text = "Translator not initialized - check API key"
                                  
                self.updater(new_translated_text)

    @pyqtSlot()
    def close_button(self):
        """Handle close button click"""
        self.running = False
        QGuiApplication.quit()
    
    @pyqtSlot(int, int, int, str, str)
    def save_settings(self, width, height, text_size, text_color, text_font):
        """Save settings to config file"""
        config = self.config_manager.load_config()
        config['window_width'] = width
        config['window_height'] = height
        config['text_size'] = text_size
        config['text_color'] = text_color
        config['text_font'] = text_font
        success = self.config_manager.save_config(config)
        
        if success:
            self.show_notification("Successfully saved settings", "success")
        else:
            self.show_notification("Failed to save settings", "error")
    
    @pyqtSlot(str)
    def save_prompt(self, prompt):
        """Save prompt and reinitialize translator"""
        config = self.config_manager.load_config()
        config['prompt'] = prompt
        self.config_manager.save_config(config)
        
        print("Prompt saved. Reinitializing translator...")
        success = self.reinitialize_translator()
        
        if success:
            self.show_notification("Successfully saved prompt", "success")
        else:
            self.show_notification("Failed to save prompt", "error")
    
    @pyqtSlot(str)
    def save_model(self, model_name):
        """Save selected model and reinitialize translator"""
        config = self.config_manager.load_config()
        config['selected_model'] = model_name
        self.config_manager.save_config(config)
        
        print(f"Model changed to {model_name}. Reinitializing translator...")
        success = self.reinitialize_translator()
        
        if success:
            self.show_notification(f"Successfully switched to {model_name}", "success")
        else:
            self.show_notification(f"Failed to initialize {model_name}", "error")
    
    @pyqtSlot(result=QVariant)
    def get_available_models(self):
        """Return list of available models"""
        models = ModelRegistry.get_model_names()
        print(f"Available models from backend: {models}")
        return models
    
    @pyqtSlot(result=QVariant)
    def get_required_api_keys(self):
        """Return list of required API key names"""
        return ModelRegistry.get_all_required_keys()
    
    @pyqtSlot(str, result=QVariant)
    def get_all_keys_for(self, key_name):
        """Get all API keys for a specific key name"""
        return self.api_key_manager.get_all_keys(key_name)
    
    @pyqtSlot(str, result=int)
    def get_active_key_index(self, key_name):
        """Get the index of the active key"""
        return self.api_key_manager.get_active_index(key_name)
    
    @pyqtSlot(str, int, result=str)
    def get_api_key_masked(self, model_name, index):
        """Get masked version of a specific API key"""
        return self.api_key_manager.get_masked_key(model_name, index)
    
    @pyqtSlot(str, str)
    def add_api_key(self, key_name, key_value):
        """Add a new API key"""
        if self.api_key_manager.add_key(key_name, key_value):
            print(f"API key added for {key_name}")
            self.show_notification(f"API key added for {key_name}", "success")
        else:
            print(f"Failed to add API key for {key_name}")
            self.show_notification("Failed to add API key", "error")
    
    @pyqtSlot(str, int)
    def delete_api_key(self, key_name, index):
        """Delete an API key by index"""
        if self.api_key_manager.delete_key(key_name, index):
            print(f"API key deleted for {key_name}")
            self.show_notification("API key deleted", "info")
        else:
            print(f"Failed to delete API key for {key_name}")
            self.show_notification("Failed to delete API key", "error")
    
    @pyqtSlot(str, int)
    def set_active_key(self, key_name, index):
        """Set the active API key and reinitialize translator"""
        if self.api_key_manager.set_active_key(key_name, index):
            print(f"Active key set to index {index} for {key_name}")
            # Reinitialize translator if this key is for the current model
            config = self.config_manager.load_config()
            selected_model = config.get('selected_model', 'Gemini')
            current_key_name = ModelRegistry.get_api_key_name(selected_model)
            if current_key_name == key_name:
                print("Reinitializing translator with new active key...")
                success = self.reinitialize_translator()
                if success:
                    self.show_notification(f"Active key changed for {key_name}", "success")
                else:
                    self.show_notification("Failed to initialize with new key", "error")
            else:
                self.show_notification(f"Active key set for {key_name}", "success")
        else:
            print(f"Failed to set active key for {key_name}")
            self.show_notification("Failed to set active key", "error")
    
    @pyqtSlot(str, result=bool)
    def has_api_key(self, key_name):
        """Check if any API keys are set"""
        return self.api_key_manager.has_keys(key_name)