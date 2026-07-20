"""
Tests for ModelRegistry
"""

import pytest
from src.translators.model_registry import ModelRegistry


class TestModelRegistry:
    """Test suite for ModelRegistry class"""
    
    def test_get_model_names(self):
        """Test getting list of available model names"""
        models = ModelRegistry.get_model_names()
        
        assert isinstance(models, list)
        assert len(models) > 0
        assert 'Gemini' in models
        assert 'DeepSeek' in models
    
    def test_get_api_key_name(self):
        """Test getting API key name for a model"""
        gemini_key = ModelRegistry.get_api_key_name('Gemini')
        assert gemini_key == 'GEMINI_API_KEY'
        
        deepseek_key = ModelRegistry.get_api_key_name('DeepSeek')
        assert deepseek_key == 'DEEPSEEK_API_KEY'
    
    def test_get_api_key_name_invalid_model(self):
        """Test getting API key name for invalid model"""
        result = ModelRegistry.get_api_key_name('InvalidModel')
        assert result is None
    
    def test_is_valid_model(self):
        """Test checking if a model is valid"""
        assert ModelRegistry.is_valid_model('Gemini') is True
        assert ModelRegistry.is_valid_model('DeepSeek') is True
        assert ModelRegistry.is_valid_model('InvalidModel') is False
    
    def test_get_all_required_keys(self):
        """Test getting all required API key names"""
        keys = ModelRegistry.get_all_required_keys()
        
        assert isinstance(keys, list)
        assert len(keys) > 0
        assert 'GEMINI_API_KEY' in keys
        assert 'DEEPSEEK_API_KEY' in keys
    
    def test_create_translator_without_api_key(self):
        """Test that creating translator without API key raises error"""
        with pytest.raises(ValueError, match="API key not set"):
            ModelRegistry.create_translator('Gemini', 'test prompt', None)
    
    def test_create_translator_invalid_model(self):
        """Test that creating translator with invalid model raises error"""
        with pytest.raises(ValueError, match="Unknown model"):
            ModelRegistry.create_translator('InvalidModel', 'test prompt', 'fake_key')
    
    def test_models_dict_structure(self):
        """Test that MODELS dict has correct structure"""
        models = ModelRegistry.MODELS
        
        assert isinstance(models, dict)
        
        for model_name, (translator_class, api_key_name) in models.items():
            # Check model name is a string
            assert isinstance(model_name, str)
            
            # Check translator class is callable
            assert callable(translator_class)
            
            # Check API key name is a string or None
            if api_key_name is not None:
                assert isinstance(api_key_name, str)
                assert api_key_name.endswith('_API_KEY')
                
    def test_local_llm_registration(self):
        """Test that Local LLM is registered correctly"""
        assert 'Local LLM' in ModelRegistry.get_model_names()
        assert ModelRegistry.get_api_key_name('Local LLM') is None
        
    def test_create_translator_local_llm(self):
        """Test that creating local LLM translator works without API key"""
        from src.translators.local_llm_module import LocalLLMTranslator
        translator = ModelRegistry.create_translator('Local LLM', 'test prompt', None)
        assert isinstance(translator, LocalLLMTranslator)
        assert translator.context == 'test prompt'

    def test_local_llm_translator_translation(self, monkeypatch):
        """Test that LocalLLMTranslator translates text correctly by mocking OpenAI client"""
        from src.translators.local_llm_module import LocalLLMTranslator
        
        class MockChoice:
            def __init__(self):
                class MockMessage:
                    content = "Mocked English translation"
                self.message = MockMessage()
                
        class MockResponse:
            choices = [MockChoice()]
            
        def mock_create(*args, **kwargs):
            return MockResponse()
            
        # Initialize translator
        translator = LocalLLMTranslator(None, "You are a translator.")
        
        # Monkeypatch the completions.create method
        monkeypatch.setattr(translator.client.chat.completions, "create", mock_create)
        
        translation = translator.translate_text("日本語")
        assert translation == "Mocked English translation"