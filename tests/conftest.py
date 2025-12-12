"""
Pytest configuration and fixtures.
"""

import pytest
import logging


@pytest.fixture(autouse=True)
def setup_logging():
    """Setup logging for tests."""
    logging.basicConfig(
        level=logging.DEBUG,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )


@pytest.fixture
def temp_config_file(tmp_path):
    """Create a temporary configuration file."""
    config_file = tmp_path / "config.yaml"
    config_content = """
agent_name: test-agent
environment: test
collection_interval: 30
cpu_threshold: 80.0
memory_threshold: 85.0
disk_threshold: 90.0
"""
    config_file.write_text(config_content)
    return str(config_file)
