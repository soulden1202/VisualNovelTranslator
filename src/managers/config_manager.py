import json
import os
from pathlib import Path

class ConfigManager:
    def __init__(self, config_file='config.json'):
        self.config_file = config_file
        self.default_config = {
            'window_width': 1000,
            'window_height': 200,
            'window_opacity': 0.1,
            'text_color': '#FFFFFF',
            'text_size': 20,
            'text_font': 'Arial',
            'prompt': 'You are a translator specializing in Japanese visual novels. Translate all text from Japanese into natural, fluent English, and also provide the romaji. Do not explain your reasoning. Only provide the romaji and English translation, with the romaji first, followed by the English. Ensure that character genders are preserved correctly, and that the translation is consistent and connected to the overall story context.',
            'selected_model': 'Gemini'
        }
    
    def load_config(self):
        """Load configuration from file, or return defaults if file doesn't exist"""
        if os.path.exists(self.config_file):
            try:
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    config = json.load(f)
                    # Merge with defaults in case new settings were added
                    return {**self.default_config, **config}
            except (json.JSONDecodeError, IOError) as e:
                print(f"Error loading config: {e}. Using defaults.")
                return self.default_config.copy()
        else:
            return self.default_config.copy()
    
    def save_config(self, config):
        """Save configuration to file"""
        try:
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(config, f, indent=4, ensure_ascii=False)
            return True
        except IOError as e:
            print(f"Error saving config: {e}")
            return False
    
    def get(self, key, default=None):
        """Get a specific config value"""
        config = self.load_config()
        return config.get(key, default)
    
    def set(self, key, value):
        """Set a specific config value"""
        config = self.load_config()
        config[key] = value
        return self.save_config(config)