"""
Tests for the AIOps Agent configuration module.
"""

import pytest
import os
from aiops_agent.config import AgentConfig


class TestAgentConfig:
    """Test cases for AgentConfig."""
    
    def test_default_configuration(self):
        """Test that default configuration is loaded correctly."""
        config = AgentConfig()
        
        assert config.agent_name is not None
        assert config.environment is not None
        assert config.collection_interval > 0
        assert config.cpu_threshold > 0
        assert config.memory_threshold > 0
        assert config.disk_threshold > 0
    
    def test_environment_variable_override(self, monkeypatch):
        """Test that environment variables override defaults."""
        monkeypatch.setenv('AGENT_NAME', 'test-agent')
        monkeypatch.setenv('COLLECTION_INTERVAL', '30')
        monkeypatch.setenv('CPU_THRESHOLD', '75.0')
        
        config = AgentConfig()
        
        assert config.agent_name == 'test-agent'
        assert config.collection_interval == 30
        assert config.cpu_threshold == 75.0
    
    def test_to_dict(self):
        """Test configuration conversion to dictionary."""
        config = AgentConfig()
        config_dict = config.to_dict()
        
        assert isinstance(config_dict, dict)
        assert 'agent_name' in config_dict
        assert 'environment' in config_dict
        assert 'collection_interval' in config_dict
