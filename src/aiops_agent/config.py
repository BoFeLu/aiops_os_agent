"""
Configuration management for the AIOps Agent.
"""

import os
import yaml
from typing import Optional, Dict, Any
from dataclasses import dataclass, field


@dataclass
class AgentConfig:
    """Configuration for the AIOps Agent."""
    
    # Agent identification
    agent_name: str = field(default_factory=lambda: os.getenv('AGENT_NAME', 'aiops-agent'))
    environment: str = field(default_factory=lambda: os.getenv('ENVIRONMENT', 'production'))
    
    # Monitoring settings
    collection_interval: int = field(default_factory=lambda: int(os.getenv('COLLECTION_INTERVAL', '60')))
    metrics_export_enabled: bool = field(default_factory=lambda: os.getenv('METRICS_EXPORT_ENABLED', 'true').lower() == 'true')
    
    # Anomaly detection settings
    anomaly_detection_enabled: bool = field(default_factory=lambda: os.getenv('ANOMALY_DETECTION_ENABLED', 'true').lower() == 'true')
    cpu_threshold: float = field(default_factory=lambda: float(os.getenv('CPU_THRESHOLD', '80.0')))
    memory_threshold: float = field(default_factory=lambda: float(os.getenv('MEMORY_THRESHOLD', '85.0')))
    disk_threshold: float = field(default_factory=lambda: float(os.getenv('DISK_THRESHOLD', '90.0')))
    
    # Alerting settings
    alert_enabled: bool = field(default_factory=lambda: os.getenv('ALERT_ENABLED', 'true').lower() == 'true')
    alert_webhook_url: Optional[str] = field(default_factory=lambda: os.getenv('ALERT_WEBHOOK_URL'))
    alert_webhook_timeout: int = field(default_factory=lambda: int(os.getenv('ALERT_WEBHOOK_TIMEOUT', '10')))
    
    # Logging settings
    log_level: str = field(default_factory=lambda: os.getenv('LOG_LEVEL', 'INFO'))
    log_format: str = field(default_factory=lambda: os.getenv('LOG_FORMAT', 'json'))
    
    @classmethod
    def from_file(cls, config_file: str) -> 'AgentConfig':
        """
        Load configuration from a YAML file.
        
        Args:
            config_file: Path to the configuration file
            
        Returns:
            AgentConfig instance
        """
        with open(config_file, 'r') as f:
            config_data = yaml.safe_load(f)
        
        return cls(**config_data)
    
    def to_dict(self) -> Dict[str, Any]:
        """
        Convert configuration to dictionary.
        
        Returns:
            Dictionary representation of the configuration
        """
        return {
            'agent_name': self.agent_name,
            'environment': self.environment,
            'collection_interval': self.collection_interval,
            'metrics_export_enabled': self.metrics_export_enabled,
            'anomaly_detection_enabled': self.anomaly_detection_enabled,
            'cpu_threshold': self.cpu_threshold,
            'memory_threshold': self.memory_threshold,
            'disk_threshold': self.disk_threshold,
            'alert_enabled': self.alert_enabled,
            'log_level': self.log_level,
            'log_format': self.log_format
        }
