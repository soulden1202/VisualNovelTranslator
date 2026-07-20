import json
import os
from pathlib import Path

class ConfigManager:
    def __init__(self, config_file='config.json', prompt_file='prompt.txt'):
        self.config_file = config_file
        self.prompt_file = prompt_file
        self.default_config = {
            'window_width': 1000,
            'window_height': 200,
            'window_opacity': 0.1,
            'text_color': '#FFFFFF',
            'text_size': 20,
            'text_font': 'Arial',
            'prompt': 'You are a translator specializing in Japanese visual novels. Translate all text from Japanese into natural, fluent English, and also provide the romaji. Do not explain your reasoning. Only provide the romaji and English translation, with the romaji first, followed by the English. Ensure that character genders are preserved correctly, and that the translation is consistent and connected to the overall story context.',
            'selected_model': 'Gemini',
            'local_llm_url': 'http://localhost:11434/v1',
            'local_llm_model': 'gemma4',
            'textractor_path': ''
        }
    
    def load_config(self):
        """Load configuration from file, or return defaults if file doesn't exist"""
        config = self.default_config.copy()
        if os.path.exists(self.config_file):
            try:
                with open(self.config_file, 'r', encoding='utf-8') as f:
                    loaded = json.load(f)
                    config.update(loaded)
            except (json.JSONDecodeError, IOError) as e:
                print(f"Error loading config: {e}. Using defaults.")

        # A saved value that's blank (e.g. text_font: "" from an earlier save
        # made before the field was ever set) overrides a real default with
        # nothing usable. Treat blank the same as "not saved yet" so it
        # self-heals back to the default instead of staying empty forever.
        for key, default_value in self.default_config.items():
            if isinstance(default_value, str) and default_value and not str(config.get(key, '')).strip():
                config[key] = default_value

        # Load from self.prompt_file if it exists, otherwise create it with the default prompt
        prompt_file = self.prompt_file
        if os.path.exists(prompt_file):
            try:
                with open(prompt_file, 'r', encoding='utf-8') as f:
                    file_prompt = f.read().strip()
                if file_prompt:
                    config['prompt'] = file_prompt
                else:
                    # Blank file -- rewrite it with the restored default so
                    # it self-heals on disk too, instead of staying blank
                    # on every future load
                    with open(prompt_file, 'w', encoding='utf-8') as f:
                        f.write(config['prompt'])
            except Exception as e:
                print(f"Error reading {prompt_file}: {e}")
        else:
            try:
                os.makedirs(os.path.dirname(os.path.abspath(prompt_file)), exist_ok=True)
                with open(prompt_file, 'w', encoding='utf-8') as f:
                    f.write(config['prompt'])
                print(f"Created default {prompt_file}")
            except Exception as e:
                print(f"Error writing default {prompt_file}: {e}")

        return config
    
    def save_config(self, config):
        """Save configuration to file"""
        # Save prompt to prompt_file as well
        prompt_file = self.prompt_file
        try:
            os.makedirs(os.path.dirname(os.path.abspath(prompt_file)), exist_ok=True)
            with open(prompt_file, 'w', encoding='utf-8') as f:
                f.write(config.get('prompt', ''))
        except Exception as e:
            print(f"Error saving prompt to {prompt_file}: {e}")

        try:
            os.makedirs(os.path.dirname(os.path.abspath(self.config_file)), exist_ok=True)
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