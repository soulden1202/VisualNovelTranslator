import json
import os
from pathlib import Path
import base64

class APIKeyManager:
    """Manages multiple API keys per model with basic obfuscation"""
    
    def __init__(self, keys_file='api_keys.json'):
        self.keys_file = keys_file
        self.keys = self._load_keys()
    
    def _obfuscate(self, text):
        """Basic obfuscation (not encryption, just makes it less obvious)"""
        if not text:
            return ""
        return base64.b64encode(text.encode()).decode()
    
    def _deobfuscate(self, text):
        """Reverse the obfuscation"""
        if not text:
            return ""
        try:
            return base64.b64decode(text.encode()).decode()
        except:
            return ""
    
    def _load_keys(self):
        """Load API keys from file
        Format: {
            'GEMINI_API_KEY': {
                'keys': ['key1', 'key2', ...],
                'active_index': 0
            }
        }
        """
        if os.path.exists(self.keys_file):
            try:
                with open(self.keys_file, 'r', encoding='utf-8') as f:
                    obfuscated_data = json.load(f)
                    # Deobfuscate all keys
                    deobfuscated = {}
                    for key_name, data in obfuscated_data.items():
                        deobfuscated[key_name] = {
                            'keys': [self._deobfuscate(k) for k in data.get('keys', [])],
                            'active_index': data.get('active_index', 0)
                        }
                    return deobfuscated
            except (json.JSONDecodeError, IOError) as e:
                print(f"Error loading API keys: {e}")
                return {}
        return {}
    
    def _save_keys(self):
        """Save API keys to file with obfuscation"""
        try:
            # Obfuscate all keys before saving
            obfuscated_data = {}
            for key_name, data in self.keys.items():
                obfuscated_data[key_name] = {
                    'keys': [self._obfuscate(k) for k in data.get('keys', [])],
                    'active_index': data.get('active_index', 0)
                }
            with open(self.keys_file, 'w', encoding='utf-8') as f:
                json.dump(obfuscated_data, f, indent=4)
            return True
        except IOError as e:
            print(f"Error saving API keys: {e}")
            return False
    
    def get_active_key(self, key_name):
        """Get the currently active API key"""
        if key_name not in self.keys:
            return ""
        data = self.keys[key_name]
        keys = data.get('keys', [])
        active_index = data.get('active_index', 0)
        if 0 <= active_index < len(keys):
            return keys[active_index]
        return ""
    
    def add_key(self, key_name, key_value):
        """Add a new API key to the list"""
        if key_name not in self.keys:
            self.keys[key_name] = {'keys': [], 'active_index': 0}
        
        # Don't add duplicates
        if key_value not in self.keys[key_name]['keys']:
            self.keys[key_name]['keys'].append(key_value)
        
        return self._save_keys()
    
    def delete_key(self, key_name, index):
        """Delete a specific API key by index"""
        if key_name not in self.keys:
            return False
        
        keys = self.keys[key_name]['keys']
        if 0 <= index < len(keys):
            keys.pop(index)
            # Adjust active index if needed
            if self.keys[key_name]['active_index'] >= len(keys):
                self.keys[key_name]['active_index'] = max(0, len(keys) - 1)
            return self._save_keys()
        return False
    
    def set_active_key(self, key_name, index):
        """Set which key is currently active"""
        if key_name not in self.keys:
            return False
        
        keys = self.keys[key_name]['keys']
        if 0 <= index < len(keys):
            self.keys[key_name]['active_index'] = index
            return self._save_keys()
        return False
    
    def get_all_keys(self, key_name):
        """Get all keys for a specific key name"""
        if key_name not in self.keys:
            return []
        return self.keys[key_name].get('keys', [])
    
    def get_active_index(self, key_name):
        """Get the index of the currently active key"""
        if key_name not in self.keys:
            return -1
        return self.keys[key_name].get('active_index', 0)
    
    def has_keys(self, key_name):
        """Check if any keys exist for this key name"""
        if key_name not in self.keys:
            return False
        return len(self.keys[key_name].get('keys', [])) > 0
    
    def get_masked_key(self, model_name, index):
        """Get a masked version of a specific key"""
        if model_name not in self.keys:
            return "Not set"
        keys = self.keys[model_name].get('keys', [])
        if 0 <= index < len(keys):
            key = keys[index]
            if len(key) < 8:
                return "***"
            return f"{key[:4]}...{key[-4:]}"
        return "Not set"