"""
System metrics collection module.
"""

import logging
import time
import psutil
from typing import Dict, Any
from .config import AgentConfig

logger = logging.getLogger(__name__)


class MetricsCollector:
    """Collects system metrics for monitoring."""
    
    def __init__(self, config: AgentConfig):
        """
        Initialize the metrics collector.
        
        Args:
            config: Agent configuration
        """
        self.config = config
        self.start_time = time.time()
        logger.info("Metrics collector initialized")
    
    def collect(self) -> Dict[str, Any]:
        """
        Collect current system metrics.
        
        Returns:
            Dictionary containing system metrics
        """
        metrics = {}
        
        try:
            # CPU metrics
            cpu_percent = psutil.cpu_percent(interval=1)
            cpu_count = psutil.cpu_count()
            metrics['cpu'] = {
                'usage_percent': cpu_percent,
                'count': cpu_count,
                'per_cpu': psutil.cpu_percent(interval=1, percpu=True)
            }
            
            # Memory metrics
            memory = psutil.virtual_memory()
            metrics['memory'] = {
                'total': memory.total,
                'available': memory.available,
                'used': memory.used,
                'percent': memory.percent
            }
            
            # Disk metrics
            disk = psutil.disk_usage('/')
            metrics['disk'] = {
                'total': disk.total,
                'used': disk.used,
                'free': disk.free,
                'percent': disk.percent
            }
            
            # Network metrics
            net_io = psutil.net_io_counters()
            metrics['network'] = {
                'bytes_sent': net_io.bytes_sent,
                'bytes_recv': net_io.bytes_recv,
                'packets_sent': net_io.packets_sent,
                'packets_recv': net_io.packets_recv
            }
            
            # System info
            metrics['system'] = {
                'uptime': time.time() - psutil.boot_time(),
                'load_average': psutil.getloadavg() if hasattr(psutil, 'getloadavg') else None
            }
            
            logger.debug(f"Collected metrics for {self.config.agent_name}")
            
        except Exception as e:
            logger.error(f"Error collecting metrics: {e}", exc_info=True)
            
        return metrics
