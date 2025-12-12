"""
Alert management and notification module.
"""

import logging
import json
from typing import Dict, Any
from datetime import datetime
import requests
from .config import AgentConfig

logger = logging.getLogger(__name__)


class AlertManager:
    """Manages alerts and notifications for detected anomalies."""
    
    def __init__(self, config: AgentConfig):
        """
        Initialize the alert manager.
        
        Args:
            config: Agent configuration
        """
        self.config = config
        logger.info("Alert manager initialized")
    
    def send_alert(self, anomaly: Dict[str, Any]):
        """
        Send alert for detected anomaly.
        
        Args:
            anomaly: Anomaly details dictionary
        """
        if not self.config.alert_enabled:
            logger.debug("Alerting is disabled, skipping alert")
            return
        
        try:
            alert_data = {
                'agent_name': self.config.agent_name,
                'environment': self.config.environment,
                'timestamp': datetime.utcnow().isoformat(),
                'anomaly': anomaly
            }
            
            # Log the alert
            logger.warning(f"ALERT: {anomaly['message']} (Severity: {anomaly['severity']})")
            
            # Send webhook if configured
            if self.config.alert_webhook_url:
                self._send_webhook(alert_data)
            
        except Exception as e:
            logger.error(f"Error sending alert: {e}", exc_info=True)
    
    def _send_webhook(self, alert_data: Dict[str, Any]):
        """
        Send alert via webhook.
        
        Args:
            alert_data: Alert data to send
        """
        try:
            response = requests.post(
                self.config.alert_webhook_url,
                json=alert_data,
                timeout=10,
                headers={'Content-Type': 'application/json'}
            )
            response.raise_for_status()
            logger.info(f"Alert sent successfully via webhook")
            
        except requests.RequestException as e:
            logger.error(f"Error sending webhook alert: {e}")
        except Exception as e:
            logger.error(f"Unexpected error sending webhook: {e}", exc_info=True)
