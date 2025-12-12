"""
Integration tests for the AIOps Agent.
"""

import pytest
import time
from aiops_agent.config import AgentConfig
from aiops_agent.agent import AIOpsAgent


class TestAIOpsAgentIntegration:
    """Integration tests for the complete AIOps Agent."""
    
    @pytest.fixture
    def config(self):
        """Create a test configuration."""
        config = AgentConfig()
        config.collection_interval = 1  # Fast collection for testing
        config.alert_enabled = False  # Disable alerts for tests
        return config
    
    @pytest.fixture
    def agent(self, config):
        """Create an agent instance."""
        return AIOpsAgent(config)
    
    def test_agent_initialization(self, agent):
        """Test that the agent initializes correctly."""
        assert agent is not None
        assert agent.config is not None
        assert agent.metrics_collector is not None
        assert agent.anomaly_detector is not None
        assert agent.alert_manager is not None
    
    def test_health_check(self, agent):
        """Test the health check functionality."""
        health = agent.health_check()
        
        assert isinstance(health, dict)
        assert 'status' in health
        assert 'agent_name' in health
        assert 'version' in health
    
    def test_agent_lifecycle(self, config):
        """Test agent start and stop lifecycle."""
        agent = AIOpsAgent(config)
        
        # Agent should not be running initially
        assert not agent.running
        
        # Start agent in a separate thread for testing
        import threading
        thread = threading.Thread(target=agent.start)
        thread.daemon = True
        thread.start()
        
        # Give it time to start
        time.sleep(2)
        assert agent.running
        
        # Stop the agent
        agent.stop()
        time.sleep(1)
        assert not agent.running
