# Multi-stage build for optimized container size
FROM python:3.11-slim as builder

# Set working directory
WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir --user -r requirements.txt

# Final stage
FROM python:3.11-slim

# Security: Create non-root user
RUN groupadd -r aiops && useradd -r -g aiops -u 1001 aiops

# Set working directory
WORKDIR /app

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Copy Python dependencies from builder
COPY --from=builder /root/.local /home/aiops/.local

# Copy application code
COPY src/ ./src/
COPY setup.py .
COPY README.md .

# Install the application
RUN pip install --no-cache-dir -e .

# Create directories for logs and data
RUN mkdir -p /app/logs /app/data && \
    chown -R aiops:aiops /app

# Security: Switch to non-root user
USER aiops

# Set environment variables
ENV PATH=/home/aiops/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    AGENT_NAME=aiops-agent \
    LOG_LEVEL=INFO \
    LOG_FORMAT=json

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD python -c "import sys; from aiops_agent.agent import AIOpsAgent; from aiops_agent.config import AgentConfig; sys.exit(0)"

# Expose port for potential metrics endpoint
EXPOSE 8080

# Run the agent
CMD ["python", "-m", "aiops_agent.main"]
