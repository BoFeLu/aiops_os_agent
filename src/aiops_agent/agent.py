"""
Core AIOps Agent implementation for system monitoring and automation.
"""

import logging
import time
import signal
import sys
from typing import Dict, Any, Optional
import psutil
import json
from datetime import datetime
from .config import AgentConfig
from .metrics_collector import MetricsCollector
from .anomaly_detector import AnomalyDetector
from .alerting import AlertManager

logger = logging.getLogger(__name__)


class AIOpsAgent:
    """
    Enterprise-grade AIOps agent for system monitoring and operations automation.
    """

    def __init__(self, config: AgentConfig):
        """
        Initialize the AIOps agent.
        
        Args:
            config: Agent configuration object
        """
        self.config = config
        self.running = False
        self.metrics_collector = MetricsCollector(config)
        self.anomaly_detector = AnomalyDetector(config)
        self.alert_manager = AlertManager(config)
        
        # Setup signal handlers for graceful shutdown
        signal.signal(signal.SIGTERM, self._handle_shutdown)
        signal.signal(signal.SIGINT, self._handle_shutdown)
        
        logger.info(f"AIOps Agent initialized with config: {config.agent_name}")

    def _handle_shutdown(self, signum, frame):
        """Handle shutdown signals gracefully."""
        logger.info(f"Received signal {signum}, initiating graceful shutdown...")
        self.stop()
        sys.exit(0)

    def start(self):
        """Start the AIOps agent monitoring loop."""
        logger.info("Starting AIOps Agent...")
        self.running = True
        
        try:
            self._run_monitoring_loop()
        except Exception as e:
            logger.error(f"Error in monitoring loop: {e}", exc_info=True)
            self.stop()
            raise

    def stop(self):
        """Stop the AIOps agent."""
        logger.info("Stopping AIOps Agent...")
        self.running = False

    def _run_monitoring_loop(self):
        """Main monitoring loop that collects metrics and detects anomalies."""
        logger.info(f"Monitoring loop started with interval: {self.config.collection_interval}s")
        
        while self.running:
            try:
                # Collect system metrics
                metrics = self.metrics_collector.collect()
                
                # Log collected metrics
                logger.debug(f"Collected metrics: {json.dumps(metrics, indent=2)}")
                
                # Detect anomalies
                anomalies = self.anomaly_detector.detect(metrics)
                
                # Handle detected anomalies
                if anomalies:
                    logger.warning(f"Detected {len(anomalies)} anomalies")
                    for anomaly in anomalies:
                        self.alert_manager.send_alert(anomaly)
                
                # Export metrics if configured
                if self.config.metrics_export_enabled:
                    self._export_metrics(metrics)
                
                # Wait for next collection interval
                time.sleep(self.config.collection_interval)
                
            except Exception as e:
                logger.error(f"Error in monitoring iteration: {e}", exc_info=True)
                time.sleep(self.config.collection_interval)

    def _export_metrics(self, metrics: Dict[str, Any]):
        """
        Export metrics to configured backends.
        
        Args:
            metrics: Collected metrics dictionary
        """
        try:
            # Add timestamp
            metrics['timestamp'] = datetime.utcnow().isoformat()
            
            # Log metrics (can be extended to push to Prometheus, etc.)
            logger.info(f"Metrics exported: {json.dumps(metrics)}")
            
        except Exception as e:
            logger.error(f"Error exporting metrics: {e}", exc_info=True)

    def health_check(self) -> Dict[str, Any]:
        """
        Perform health check and return status.
        
        Returns:
            Dictionary containing health status
        """
        return {
            "status": "healthy" if self.running else "stopped",
            "agent_name": self.config.agent_name,
            "version": "1.0.0",
            "uptime_seconds": time.time() - self.metrics_collector.start_time if hasattr(self.metrics_collector, 'start_time') else 0
        }
