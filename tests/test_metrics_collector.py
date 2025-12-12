"""
Tests for the MetricsCollector module.
"""

import pytest
from aiops_agent.config import AgentConfig
from aiops_agent.metrics_collector import MetricsCollector


class TestMetricsCollector:
    """Test cases for MetricsCollector."""
    
    @pytest.fixture
    def config(self):
        """Create a test configuration."""
        return AgentConfig()
    
    @pytest.fixture
    def collector(self, config):
        """Create a metrics collector instance."""
        return MetricsCollector(config)
    
    def test_collector_initialization(self, collector):
        """Test that the collector initializes correctly."""
        assert collector is not None
        assert collector.config is not None
        assert collector.start_time > 0
    
    def test_collect_metrics(self, collector):
        """Test that metrics are collected successfully."""
        metrics = collector.collect()
        
        assert isinstance(metrics, dict)
        assert 'cpu' in metrics
        assert 'memory' in metrics
        assert 'disk' in metrics
        assert 'network' in metrics
        assert 'system' in metrics
    
    def test_cpu_metrics(self, collector):
        """Test CPU metrics collection."""
        metrics = collector.collect()
        
        assert 'usage_percent' in metrics['cpu']
        assert 'count' in metrics['cpu']
        assert metrics['cpu']['usage_percent'] >= 0
        assert metrics['cpu']['count'] > 0
    
    def test_memory_metrics(self, collector):
        """Test memory metrics collection."""
        metrics = collector.collect()
        
        assert 'total' in metrics['memory']
        assert 'available' in metrics['memory']
        assert 'used' in metrics['memory']
        assert 'percent' in metrics['memory']
        assert metrics['memory']['total'] > 0
        assert 0 <= metrics['memory']['percent'] <= 100
    
    def test_disk_metrics(self, collector):
        """Test disk metrics collection."""
        metrics = collector.collect()
        
        assert 'total' in metrics['disk']
        assert 'used' in metrics['disk']
        assert 'free' in metrics['disk']
        assert 'percent' in metrics['disk']
        assert metrics['disk']['total'] > 0
        assert 0 <= metrics['disk']['percent'] <= 100
