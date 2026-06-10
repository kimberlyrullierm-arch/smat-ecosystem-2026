import time
import random
import json
import paho.mqtt.client as mqtt

BROKER = "broker.hivemq.com"
PUERTO = 1883
ESTACION_ID = "estacion_vitarte_01"
TOPICO = f"smat/{ESTACION_ID}/telemetria"

def main():
    cliente = mqtt.Client(callback_api_version=mqtt.CallbackAPIVersion.VERSION2)
    print(f"[SENSOR] Conectando al broker {BROKER}...")
    cliente.connect(BROKER, PUERTO, 60)
    cliente.loop_start()
    
    print(f"[SENSOR] Iniciando envío de telemetría para {ESTACION_ID}...")
    try:
        while True:
            # Simulación de datos ambientales
            temperatura = round(random.uniform(14.0, 28.0), 2)
            humedad = round(random.uniform(60.0, 95.0), 2)
            
            payload = {
                "estacion_id": ESTACION_ID,
                "temperatura": temperatura,
                "humedad": humedad,
                "timestamp": time.time()
            }
            
            mensaje = json.dumps(payload)
            cliente.publish(TOPICO, mensaje, qos=1)
            print(f"[SENSOR] Publicado en {TOPICO}: {mensaje}")
            
            time.sleep(5)  # Enviar datos cada 5 segundos
            
    except KeyboardInterrupt:
        print("\n[SENSOR] Apagando emulador...")
    finally:
        cliente.loop_stop()
        cliente.disconnect()

if __name__ == "__main__":
    main()