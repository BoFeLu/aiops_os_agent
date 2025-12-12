"""
Tests for the AnomalyDetector module.
"""

import pytest
from aiops_agent.config import AgentConfig
from aiops_agent.anomaly_detector import AnomalyDetector


class TestAnomalyDetector:
    """Test cases for AnomalyDetector."""
    
    @pytest.fixture
    def config(self):
        """Create a test configuration."""
        config = AgentConfig()
        config.cpu_threshold = 80.0
        config.memory_threshold = 85.0
        config.disk_threshold = 90.0
        return config
    
    @pytest.fixture
    def detector(self, config):
        """Create an anomaly detector instance."""
        return AnomalyDetector(config)
    
    def test_detector_initialization(self, detector):
        """Test that the detector initializes correctly."""
        assert detector is not None
        assert detector.config is not None
    
    def test_no_anomalies_normal_metrics(self, detector):
        """Test that no anomalies are detected for normal metrics."""
        metrics = {
            'cpu': {'usage_percent': 50.0},
            'memory': {'percent': 60.0},
            'disk': {'percent': 70.0}
        }
        
        anomalies = detector.detect(metrics)
        assert len(anomalies) == 0
    
    def test_cpu_anomaly_detected(self, detector):
        """Test that CPU anomaly is detected."""
        metrics = {
            'cpu': {'usage_percent': 90.0},
            'memory': {'percent': 60.0},
            'disk': {'percent': 70.0}
        }
        
        anomalies = detector.detect(metrics)
        assert len(anomalies) == 1
        assert anomalies[0]['type'] == 'cpu_high'
        assert anomalies[0]['value'] == 90.0
    
    def test_memory_anomaly_detected(self, detector):
        """Test that memory anomaly is detected."""
        metrics = {
            'cpu': {'usage_percent': 50.0},
            'memory': {'percent': 95.0},
            'disk': {'percent': 70.0}
        }
        
        anomalies = detector.detect(metrics)
        assert len(anomalies) == 1
        assert anomalies[0]['type'] == 'memory_high'
        assert anomalies[0]['value'] == 95.0
    
    def test_multiple_anomalies_detected(self, detector):
        """Test that multiple anomalies are detected."""
        metrics = {
            'cpu': {'usage_percent': 95.0},
            'memory': {'percent': 95.0},
            'disk': {'percent': 95.0}
        }
        
        anomalies = detector.detect(metrics)
        assert len(anomalies) == 3
    
    def test_anomaly_severity_levels(self, detector):
        """Test anomaly severity classification."""
        # Warning level
        metrics_warning = {
            'cpu': {'usage_percent': 85.0},
            'memory': {'percent': 60.0},
            'disk': {'percent': 70.0}
        }
        anomalies = detector.detect(metrics_warning)
        assert anomalies[0]['severity'] == 'warning'
        
        # Critical level
        metrics_critical = {
            'cpu': {'usage_percent': 98.0},
            'memory': {'percent': 60.0},
            'disk': {'percent': 70.0}
        }
        anomalies = detector.detect(metrics_critical)
        assert anomalies[0]['severity'] == 'critical'
