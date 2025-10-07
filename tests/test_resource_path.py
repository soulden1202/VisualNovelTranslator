"""
Tests for resource_path utility
"""

import pytest
import os
import sys
from src.utils.resource_path import get_resource_path


class TestResourcePath:
    """Test suite for get_resource_path function"""
    
    def test_get_resource_path_returns_string(self):
        """Test that function returns a string"""
        result = get_resource_path('test.txt')
        assert isinstance(result, str)
    
    def test_get_resource_path_joins_correctly(self):
        """Test that path is joined correctly"""
        result = get_resource_path('UI/Main.qml')
        
        # Should contain the relative path
        assert 'UI' in result
        assert 'Main.qml' in result
    
    def test_get_resource_path_absolute(self):
        """Test that returned path is absolute"""
        result = get_resource_path('test.txt')
        assert os.path.isabs(result)
    
    def test_get_resource_path_with_meipass(self, monkeypatch):
        """Test behavior when running as PyInstaller bundle"""
        test_meipass = '/tmp/test_bundle'
        
        # Mock sys._MEIPASS
        monkeypatch.setattr(sys, '_MEIPASS', test_meipass, raising=False)
        
        result = get_resource_path('UI/Main.qml')
        assert result.startswith(test_meipass)
    
    def test_get_resource_path_without_meipass(self, monkeypatch):
        """Test behavior when running in development mode"""
        # Make sure _MEIPASS doesn't exist
        if hasattr(sys, '_MEIPASS'):
            monkeypatch.delattr(sys, '_MEIPASS')
        
        result = get_resource_path('test.txt')
        
        # Should use current directory
        current_dir = os.path.abspath(".")
        assert result.startswith(current_dir)
    
    def test_get_resource_path_empty_string(self):
        """Test with empty string input"""
        result = get_resource_path('')
        assert isinstance(result, str)
        assert len(result) > 0  # Should still return a valid path
    
    def test_get_resource_path_nested_folders(self):
        """Test with nested folder structure"""
        result = get_resource_path('folder1/folder2/file.txt')
        
        assert 'folder1' in result
        assert 'folder2' in result
        assert 'file.txt' in result