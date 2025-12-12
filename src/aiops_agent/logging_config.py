"""
Logging configuration for the AIOps Agent.
"""

import logging
import sys
import json
from datetime import datetime
from .config import AgentConfig


class JsonFormatter(logging.Formatter):
    """Custom JSON formatter for structured logging."""
    
    def format(self, record):
        """Format log record as JSON."""
        log_data = {
            'timestamp': datetime.utcnow().isoformat(),
            'level': record.levelname,
            'logger': record.name,
            'message': record.getMessage(),
        }
        
        if record.exc_info:
            log_data['exception'] = self.formatException(record.exc_info)
        
        return json.dumps(log_data)


def setup_logging(config: AgentConfig):
    """
    Setup logging configuration.
    
    Args:
        config: Agent configuration
    """
    log_level = getattr(logging, config.log_level.upper(), logging.INFO)
    
    # Create handler
    handler = logging.StreamHandler(sys.stdout)
    
    # Set formatter based on config
    if config.log_format.lower() == 'json':
        formatter = JsonFormatter()
    else:
        formatter = logging.Formatter(
            '%(asctime)s - %(name)s - %(levelname)s - %(message)s'
        )
    
    handler.setFormatter(formatter)
    
    # Configure root logger
    root_logger = logging.getLogger()
    root_logger.setLevel(log_level)
    root_logger.addHandler(handler)
    
    # Set level for aiops_agent logger
    logger = logging.getLogger('aiops_agent')
    logger.setLevel(log_level)
    
    logging.info(f"Logging configured with level: {config.log_level}, format: {config.log_format}")
