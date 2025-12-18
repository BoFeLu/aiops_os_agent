FROM python:3.9-slim
WORKDIR /app
COPY agent.py .
# El estándar Summum requiere usuarios no root
RUN useradd -m aiopsuser
USER aiopsuser
CMD ["python", "agent.py"]
