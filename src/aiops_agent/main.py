"""
Main entry point for the AIOps Agent.
"""

import logging
import sys
from .config import AgentConfig
from .logging_config import setup_logging
from .agent import AIOpsAgent

logger = logging.getLogger(__name__)


def main():
    """Main function to start the AIOps Agent."""
    try:
        # Load configuration
        config = AgentConfig()
        
        # Setup logging
        setup_logging(config)
        
        logger.info("="*60)
        logger.info("Starting AIOps Agent")
        logger.info(f"Agent Name: {config.agent_name}")
        logger.info(f"Environment: {config.environment}")
        logger.info("="*60)
        
        # Create and start agent
        agent = AIOpsAgent(config)
        agent.start()
        
    except KeyboardInterrupt:
        logger.info("Received keyboard interrupt, shutting down...")
        sys.exit(0)
    except Exception as e:
        logger.error(f"Fatal error: {e}", exc_info=True)
        sys.exit(1)


if __name__ == "__main__":
    main()
