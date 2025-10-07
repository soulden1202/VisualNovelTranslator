"""
Tests for APIKeyManager
"""

import pytest
import os
from src.managers.api_key_manager import APIKeyManager


class TestAPIKeyManager:
    """Test suite for APIKeyManager class"""
    
    @pytest.fixture
    def temp_keys_file(self, tmp_path):
        """Create a temporary keys file for testing"""
        keys_file = tmp_path / "test_api_keys.json"
        return str(keys_file)
    
    @pytest.fixture
    def key_manager(self, temp_keys_file):
        """Create an APIKeyManager instance with temp file"""
        return APIKeyManager(keys_file=temp_keys_file)
    
    def test_add_key(self, key_manager):
        """Test adding a new API key"""
        result = key_manager.add_key('GEMINI_API_KEY', 'test_key_12345')
        assert result is True
        
        keys = key_manager.get_all_keys('GEMINI_API_KEY')
        assert len(keys) == 1
        assert keys[0] == 'test_key_12345'
    
    def test_add_multiple_keys(self, key_manager):
        """Test adding multiple keys for the same model"""
        key_manager.add_key('GEMINI_API_KEY', 'key1')
        key_manager.add_key('GEMINI_API_KEY', 'key2')
        key_manager.add_key('GEMINI_API_KEY', 'key3')
        
        keys = key_manager.get_all_keys('GEMINI_API_KEY')
        assert len(keys) == 3
        assert 'key1' in keys
        assert 'key2' in keys
        assert 'key3' in keys
    
    def test_no_duplicate_keys(self, key_manager):
        """Test that duplicate keys are not added"""
        key_manager.add_key('GEMINI_API_KEY', 'test_key')
        key_manager.add_key('GEMINI_API_KEY', 'test_key')  # Duplicate
        
        keys = key_manager.get_all_keys('GEMINI_API_KEY')
        assert len(keys) == 1
    
    def test_get_active_key(self, key_manager):
        """Test getting the active API key"""
        key_manager.add_key('GEMINI_API_KEY', 'active_key')
        
        active_key = key_manager.get_active_key('GEMINI_API_KEY')
        assert active_key == 'active_key'
    
    def test_set_active_key(self, key_manager):
        """Test setting which key is active"""
        key_manager.add_key('GEMINI_API_KEY', 'key1')
        key_manager.add_key('GEMINI_API_KEY', 'key2')
        key_manager.add_key('GEMINI_API_KEY', 'key3')
        
        # Set second key as active
        result = key_manager.set_active_key('GEMINI_API_KEY', 1)
        assert result is True
        
        active_key = key_manager.get_active_key('GEMINI_API_KEY')
        assert active_key == 'key2'
        
        active_index = key_manager.get_active_index('GEMINI_API_KEY')
        assert active_index == 1
    
    def test_delete_key(self, key_manager):
        """Test deleting an API key"""
        key_manager.add_key('GEMINI_API_KEY', 'key1')
        key_manager.add_key('GEMINI_API_KEY', 'key2')
        
        result = key_manager.delete_key('GEMINI_API_KEY', 0)
        assert result is True
        
        keys = key_manager.get_all_keys('GEMINI_API_KEY')
        assert len(keys) == 1
        assert keys[0] == 'key2'
    
    def test_delete_active_key_adjusts_index(self, key_manager):
        """Test that active index adjusts when active key is deleted"""
        key_manager.add_key('GEMINI_API_KEY', 'key1')
        key_manager.add_key('GEMINI_API_KEY', 'key2')
        key_manager.add_key('GEMINI_API_KEY', 'key3')
        
        key_manager.set_active_key('GEMINI_API_KEY', 2)  # Set last key active
        key_manager.delete_key('GEMINI_API_KEY', 2)  # Delete active key
        
        # Active index should adjust to last available
        active_index = key_manager.get_active_index('GEMINI_API_KEY')
        assert active_index == 1
    
    def test_has_keys(self, key_manager):
        """Test checking if keys exist"""
        assert key_manager.has_keys('GEMINI_API_KEY') is False
        
        key_manager.add_key('GEMINI_API_KEY', 'test_key')
        assert key_manager.has_keys('GEMINI_API_KEY') is True
    
    def test_get_masked_key(self, key_manager):
        """Test getting masked version of key"""
        key_manager.add_key('GEMINI_API_KEY', 'sk-1234567890abcdef')
        
        masked = key_manager.get_masked_key('GEMINI_API_KEY', 0)
        assert masked == 'sk-1...cdef'
        assert 'sk-1234567890abcdef' not in masked
    
    def test_key_persistence(self, key_manager, temp_keys_file):
        """Test that keys persist across manager instances"""
        key_manager.add_key('GEMINI_API_KEY', 'persistent_key')
        key_manager.set_active_key('GEMINI_API_KEY', 0)
        
        # Create new manager instance with same file
        new_manager = APIKeyManager(keys_file=temp_keys_file)
        
        keys = new_manager.get_all_keys('GEMINI_API_KEY')
        assert len(keys) == 1
        assert keys[0] == 'persistent_key'
        
        active_key = new_manager.get_active_key('GEMINI_API_KEY')
        assert active_key == 'persistent_key'
    
    def test_obfuscation(self, key_manager, temp_keys_file):
        """Test that keys are obfuscated in the file"""
        test_key = 'my_secret_api_key'
        key_manager.add_key('GEMINI_API_KEY', test_key)
        
        # Read raw file contents
        with open(temp_keys_file, 'r') as f:
            file_contents = f.read()
        
        # Plain key should not appear in file
        assert test_key not in file_contents
        
        # But we should still be able to retrieve it
        retrieved_key = key_manager.get_active_key('GEMINI_API_KEY')
        assert retrieved_key == test_key
    
    def test_multiple_models(self, key_manager):
        """Test managing keys for multiple models"""
        key_manager.add_key('GEMINI_API_KEY', 'gemini_key')
        key_manager.add_key('DEEPSEEK_API_KEY', 'deepseek_key')
        
        assert key_manager.has_keys('GEMINI_API_KEY')
        assert key_manager.has_keys('DEEPSEEK_API_KEY')
        
        gemini_key = key_manager.get_active_key('GEMINI_API_KEY')
        deepseek_key = key_manager.get_active_key('DEEPSEEK_API_KEY')
        
        assert gemini_key == 'gemini_key'
        assert deepseek_key == 'deepseek_key'