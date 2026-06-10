import requests
import time
import random

API_URL = "http://localhost:8000/lecturas/"
ESTACION_ID = 1
TOKEN = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJhZG1pbl9maXNpIiwiZXhwIjoxNzc5OTAzNTg0fQ.jQshKSOsnDuIRD82iGMEQCAka6_KoavBJLOe3BCoEf0"

def leer_sensor_emulado():
    return round(random.uniform(10.5, 85.0), 2)

def enviar_telemetria():
    print(f"--- Iniciando Emisor IoT para Estación {ESTACION_ID} ---")
    while True:
        valor = leer_sensor_emulado()
        es_alerta = valor > 70.0
        
        if es_alerta:
            print(f"[ALERTA] Umbral de inundación superado: {valor} cm")
            
        payload = {
            "valor": valor,
            "estacion_id": ESTACION_ID
        }
        
        headers = {
            "Authorization": f"Bearer {TOKEN}",
            "Content-Type": "application/json"
        }
        
        try:
            # Versión ultra-compatible de requests
            response = requests.post(API_URL, json=payload, headers=headers)
            
            if response.status_code == 200 or response.status_code == 201:
                print(f"[OK] Lectura enviada: {valor} cm")
            else:
                print(f"[ERROR] Código: {response.status_code}")
        except Exception as e:
            print(f"[CRÍTICO] No hay conexión con el servidor: {e}")
            
        tiempo_espera = 2 if es_alerta else 10
        print(f"Esperando {tiempo_espera} segundos...\n")
        time.sleep(tiempo_espera)

if __name__ == "__main__":
    enviar_telemetria()