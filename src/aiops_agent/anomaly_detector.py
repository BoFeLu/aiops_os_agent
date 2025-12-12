"""
Anomaly detection module for identifying system issues.
"""

import logging
from typing import Dict, Any, List
from .config import AgentConfig

logger = logging.getLogger(__name__)


class AnomalyDetector:
    """Detects anomalies in system metrics."""
    
    def __init__(self, config: AgentConfig):
        """
        Initialize the anomaly detector.
        
        Args:
            config: Agent configuration
        """
        self.config = config
        logger.info("Anomaly detector initialized")
    
    def detect(self, metrics: Dict[str, Any]) -> List[Dict[str, Any]]:
        """
        Detect anomalies in the provided metrics.
        
        Args:
            metrics: System metrics dictionary
            
        Returns:
            List of detected anomalies
        """
        if not self.config.anomaly_detection_enabled:
            return []
        
        anomalies = []
        
        try:
            # Check CPU usage
            if 'cpu' in metrics:
                cpu_usage = metrics['cpu'].get('usage_percent', 0)
                if cpu_usage > self.config.cpu_threshold:
                    anomalies.append({
                        'type': 'cpu_high',
                        'severity': 'warning' if cpu_usage < 95 else 'critical',
                        'message': f'High CPU usage: {cpu_usage:.2f}%',
                        'value': cpu_usage,
                        'threshold': self.config.cpu_threshold
                    })
            
            # Check memory usage
            if 'memory' in metrics:
                memory_percent = metrics['memory'].get('percent', 0)
                if memory_percent > self.config.memory_threshold:
                    anomalies.append({
                        'type': 'memory_high',
                        'severity': 'warning' if memory_percent < 95 else 'critical',
                        'message': f'High memory usage: {memory_percent:.2f}%',
                        'value': memory_percent,
                        'threshold': self.config.memory_threshold
                    })
            
            # Check disk usage
            if 'disk' in metrics:
                disk_percent = metrics['disk'].get('percent', 0)
                if disk_percent > self.config.disk_threshold:
                    anomalies.append({
                        'type': 'disk_high',
                        'severity': 'warning' if disk_percent < 95 else 'critical',
                        'message': f'High disk usage: {disk_percent:.2f}%',
                        'value': disk_percent,
                        'threshold': self.config.disk_threshold
                    })
            
            if anomalies:
                logger.warning(f"Detected {len(anomalies)} anomalies")
            
        except Exception as e:
            logger.error(f"Error detecting anomalies: {e}", exc_info=True)
        
        return anomalies
