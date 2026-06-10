import json
import time  
import requests
import paho.mqtt.client as mqtt
import sys

BROKER = "broker.hivemq.com"
PUERTO = 1883
TOPICO = "fisi/smat/estaciones/+/lecturas" 
API_URL = "http://localhost:8000/lecturas/"
print("API URL ACTUAL:", API_URL)

# =====================================================================
# MODIFICACIÓN LAB 11: Caché en memoria para el Filtro por Umbral
# =====================================================================

#Modificacion de cache
cache_local = {}

def evaluar_filtro_deadband(estacion_id, nueva_temp, nueva_hum):
    ahora = time.time()
    
    # Condición 0: Si es el primer mensaje de la estación, pasa directo para llenar la caché
    if estacion_id not in cache_local:
        return True
        
    datos_previos = cache_local[estacion_id]
    temp_ant = datos_previos["temperatura"]
    hum_ant = datos_previos["humedad"]
    tiempo_ant = datos_previos["timestamp"]
    
    # Condición 1: Reporte mínimo de vida (¿Pasaron más de 60 segundos?)
    if ahora - tiempo_ant > 60:
        print(f"[FILTRO] -> {estacion_id} superó los 60 segundos sin reportar. Forzando envío.")
        return True
        
    # Condición 2: Variación mayor al ± 5% (Exigencia de la guía Lab 11)
    variacion_temp = abs(nueva_temp - temp_ant) / (temp_ant if temp_ant != 0 else 1)
    variacion_hum = abs(nueva_hum - hum_ant) / (hum_ant if hum_ant != 0 else 1)
    
    if variacion_temp > 0.05 or variacion_hum > 0.05:
        print(f"[FILTRO] -> {estacion_id} varió más del 5% (ΔT: {variacion_temp*100:.1f}% | ΔH: {variacion_hum*100:.1f}%)")
        return True
        
    # Si los datos no cambiaron significativamente, se bloquean
    return False
# =====================================================================

def on_connect(client, userdata, flags, rc, properties):
    if rc == 0:
        print("[BRIDGE] Conectado al Broker MQTT. Suscribiéndose a tópicos...")
        client.subscribe(TOPICO)
    else:
        print(f"[BRIDGE] Error de conexión: {rc}")

def on_message(client, userdata, msg):
    payload_raw = msg.payload.decode()
    print(f"\n[BRIDGE] Mensaje recibido en MQTT: {payload_raw}")
    
    try:
        datos = json.loads(payload_raw)
        
        # Extraemos los valores clave del JSON para pasarlos por el filtro
        estacion_id = datos.get("estacion_id")
        nueva_temp = datos.get("temperatura")
        nueva_hum = datos.get("humedad")
        
        # Aplicamos el filtro Deadband del Laboratorio 11
        if evaluar_filtro_deadband(estacion_id, nueva_temp, nueva_hum):
            
            # Si el filtro aprueba el dato, actualizamos nuestra caché local
            cache_local[estacion_id] = {
                "temperatura": nueva_temp,
                "humedad": nueva_hum,
                "timestamp": time.time()
            }
            
            # Reenviar los datos recibidos de MQTT hacia el Backend mediante HTTP POST
            response = requests.post(API_URL, json=datos)
            
            if response.status_code == 200 or response.status_code == 201:
                print("\033[92m[BRIDGE] -> Datos RELEVANTES reenviados exitosamente a la API REST\033[0m")
            else:
                print(f"[BRIDGE] -> Error al enviar a la API: Código {response.status_code}")
        else:
            # Si el filtro da False, evitamos hacer el POST y ahorramos red/base de datos
            print(f"\033[94m[BRIDGE] -> [FILTRADO] Datos redundantes bloqueados para {estacion_id}. Red optimizada.\033[0m")
            
    except json.JSONDecodeError:
        print("[BRIDGE] Error: El payload no es un JSON válido.")
    except requests.exceptions.ConnectionError:
        print("[BRIDGE] Error crítico: No se pudo conectar con la API REST. ¿Está encendido el servidor?")

def main():
    cliente = mqtt.Client(callback_api_version=mqtt.CallbackAPIVersion.VERSION2)
    cliente.on_connect = on_connect
    cliente.on_message = on_message
    
    cliente.connect(BROKER, PUERTO, 60)
    cliente.loop_forever()

if __name__ == "__main__":
    main()