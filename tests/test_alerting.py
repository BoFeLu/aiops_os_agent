"""
Tests for the AlertManager module.
"""

import pytest
from unittest.mock import Mock, patch
from aiops_agent.config import AgentConfig
from aiops_agent.alerting import AlertManager


class TestAlertManager:
    """Test cases for AlertManager."""
    
    @pytest.fixture
    def config(self):
        """Create a test configuration."""
        config = AgentConfig()
        config.alert_enabled = True
        config.alert_webhook_url = 'https://example.com/webhook'
        return config
    
    @pytest.fixture
    def alert_manager(self, config):
        """Create an alert manager instance."""
        return AlertManager(config)
    
    def test_alert_manager_initialization(self, alert_manager):
        """Test that the alert manager initializes correctly."""
        assert alert_manager is not None
        assert alert_manager.config is not None
    
    def test_send_alert_disabled(self):
        """Test that alerts are not sent when disabled."""
        config = AgentConfig()
        config.alert_enabled = False
        alert_manager = AlertManager(config)
        
        anomaly = {
            'type': 'cpu_high',
            'severity': 'warning',
            'message': 'High CPU usage',
            'value': 85.0
        }
        
        # Should not raise any errors
        alert_manager.send_alert(anomaly)
    
    @patch('aiops_agent.alerting.requests.post')
    def test_send_webhook_alert(self, mock_post, alert_manager):
        """Test sending alert via webhook."""
        mock_post.return_value.status_code = 200
        
        anomaly = {
            'type': 'cpu_high',
            'severity': 'warning',
            'message': 'High CPU usage',
            'value': 85.0
        }
        
        alert_manager.send_alert(anomaly)
        
        assert mock_post.called
        args, kwargs = mock_post.call_args
        assert args[0] == 'https://example.com/webhook'
        assert 'json' in kwargs
        assert 'anomaly' in kwargs['json']
    
    @patch('aiops_agent.alerting.requests.post')
    def test_webhook_error_handling(self, mock_post, alert_manager):
        """Test webhook error handling."""
        mock_post.side_effect = Exception('Connection error')
        
        anomaly = {
            'type': 'cpu_high',
            'severity': 'warning',
            'message': 'High CPU usage',
            'value': 85.0
        }
        
        # Should not raise exception
        alert_manager.send_alert(anomaly)
