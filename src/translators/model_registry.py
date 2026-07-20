"""
Model Registry - Central place to register and manage translation models
Add new models here to make them available in the settings
"""

from src.translators.gemini_module import GeminiTranslator
from src.translators.deepseek_module import DeepSeekTranslator
from src.translators.local_llm_module import LocalLLMTranslator


class ModelRegistry:
    """Registry for managing available translation models"""
    
    # Define all available models here
    # Format: 'Display Name': (Class, api_key_name)
    MODELS = {
        'Gemini': (GeminiTranslator, 'GEMINI_API_KEY'),
        'DeepSeek': (DeepSeekTranslator, 'DEEPSEEK_API_KEY'),
        'Local LLM': (LocalLLMTranslator, None),
    }
    
    @classmethod
    def get_model_names(cls):
        """Get list of available model names"""
        return list(cls.MODELS.keys())
    
    @classmethod
    def get_api_key_name(cls, model_name):
        """Get the API key name for a model"""
        if model_name not in cls.MODELS:
            return None
        return cls.MODELS[model_name][1]
    
    @classmethod
    def create_translator(cls, model_name, prompt, api_key):
        """Create a translator instance for the specified model"""
        if model_name not in cls.MODELS:
            raise ValueError(f"Unknown model: {model_name}. Available models: {cls.get_model_names()}")
        
        translator_class, api_key_name = cls.MODELS[model_name]
        
        if api_key_name and not api_key:
            raise ValueError(f"API key not set for {model_name}. Please add it in Settings > API Keys.")
        
        return translator_class(api_key, prompt)
    
    @classmethod
    def is_valid_model(cls, model_name):
        """Check if a model name is valid"""
        return model_name in cls.MODELS
    
    @classmethod
    def get_all_required_keys(cls):
        """Get all API key names required by registered models"""
        return list(set(key_name for _, key_name in cls.MODELS.values() if key_name))