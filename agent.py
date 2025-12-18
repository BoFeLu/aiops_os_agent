import time
import os

print("--- AIOps OS Agent | Standard Summum ---")
print(f"Estado: Operativo")
print(f"Namespace: {os.getenv('KART_NAMESPACE', 'aiops')}")

while True:
    # Aquí irá tu lógica de DeepSeek/Gemini para analizar el SO
    time.sleep(60)
