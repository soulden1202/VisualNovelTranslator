"""
Tests for ConfigManager
"""

import pytest
import os
import json
from src.managers.config_manager import ConfigManager


class TestConfigManager:
    """Test suite for ConfigManager class"""
    
    @pytest.fixture
    def temp_config_file(self, tmp_path):
        """Create a temporary config file for testing"""
        config_file = tmp_path / "test_config.json"
        return str(config_file)
    
    @pytest.fixture
    def config_manager(self, temp_config_file):
        """Create a ConfigManager instance with temp file"""
        return ConfigManager(config_file=temp_config_file)
    
    def test_load_config_creates_default(self, config_manager):
        """Test that loading non-existent config returns defaults"""
        config = config_manager.load_config()
        
        assert config is not None
        assert 'window_width' in config
        assert 'window_height' in config
        assert 'text_color' in config
        assert config['window_width'] == 1000
        assert config['text_color'] == '#FFFFFF'
    
    def test_save_config(self, config_manager, temp_config_file):
        """Test saving configuration to file"""
        test_config = {
            'window_width': 1500,
            'window_height': 300,
            'text_color': '#FF0000',
            'text_size': 25,
        }
        
        result = config_manager.save_config(test_config)
        assert result is True
        assert os.path.exists(temp_config_file)
        
        # Verify file contents
        with open(temp_config_file, 'r') as f:
            saved_config = json.load(f)
        
        assert saved_config['window_width'] == 1500
        assert saved_config['text_color'] == '#FF0000'
    
    def test_load_saved_config(self, config_manager):
        """Test that saved config can be loaded back"""
        test_config = {
            'window_width': 1200,
            'window_height': 250,
            'text_size': 18,
        }
        
        config_manager.save_config(test_config)
        loaded_config = config_manager.load_config()
        
        assert loaded_config['window_width'] == 1200
        assert loaded_config['window_height'] == 250
        assert loaded_config['text_size'] == 18
    
    def test_get_specific_value(self, config_manager):
        """Test getting a specific config value"""
        config = {
            'window_width': 1000,
            'text_color': '#FFFFFF',
        }
        config_manager.save_config(config)
        
        width = config_manager.get('window_width')
        assert width == 1000
        
        color = config_manager.get('text_color')
        assert color == '#FFFFFF'
        
        # Test default value for missing key
        missing = config_manager.get('non_existent_key', 'default_value')
        assert missing == 'default_value'
    
    def test_set_specific_value(self, config_manager):
        """Test setting a specific config value"""
        result = config_manager.set('window_width', 1500)
        assert result is True
        
        width = config_manager.get('window_width')
        assert width == 1500
    
    def test_config_persistence(self, config_manager, temp_config_file):
        """Test that config persists across multiple loads"""
        config_manager.set('window_width', 1300)
        config_manager.set('text_size', 22)
        
        # Create new manager instance with same file
        new_manager = ConfigManager(config_file=temp_config_file)
        
        # Verify values persisted
        assert new_manager.get('window_width') == 1300
        assert new_manager.get('text_size') == 22
    
    def test_invalid_json_handling(self, config_manager, temp_config_file):
        """Test that invalid JSON is handled gracefully"""
        # Write invalid JSON
        with open(temp_config_file, 'w') as f:
            f.write('{ invalid json }')
        
        # Should return defaults without crashing
        config = config_manager.load_config()
        assert config is not None
        assert 'window_width' in config