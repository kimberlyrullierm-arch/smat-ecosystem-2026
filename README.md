# IOT - Monitoreo de Telemetría
Este componente simula de manera autónoma el comportamiento de un microcontrolador (como un ESP32) midiendo el nivel de un río en tiempo real.

## Funcionamiento
- **Protocolo de comunicación:** Utiliza peticiones HTTP POST hacia el backend de FastAPI.
- **Seguridad:** El dispositivo incluye de forma segura un Token JWT en las cabeceras (`Authorization: Bearer <TOKEN>`) para autenticar el envío de datos.
- **Modo de Emergencia:** Si el nivel del río supera los 70.0 cm, el script entra en estado de alerta, imprimiendo una advertencia por consola e incrementando la frecuencia de envío a cada 2 segundos para monitorear el peligro de manera crítica.

## Arquitectura del Proyecto

El ecosistema está dividido en tres componentes principales:

* **Backend (`/backend`):** API REST construida con FastAPI que gestiona la recepción de datos, autenticación mediante tokens JWT y control de CORS.
* **Mobile/Web (`/mobile`):** Aplicación en Flutter para la visualización de datos y paneles de control.
* **Simulador (`sensor_emitte.py`):** Script en Python encargado de simular la generación y envío de datos de los sensores.

---

## 🛠️ Configuraciones y Correcciones Realizadas

Durante el laboratorio se resolvieron los siguientes puntos clave para asegurar el despliegue local en entorno Web:

1.  **Compatibilidad de Red (CORS):** Se configuraron los middleware de CORS en FastAPI para permitir peticiones desde el origen de Flutter Web.
2.  **Ajuste de Endpoints:** Se migraron las direcciones IP de `10.0.2.2` (exclusiva para emuladores Android) a `127.0.0.1` en `api_service.dart` para habilitar el consumo local desde Google Chrome.
3.  **Seguridad y Autenticación:** Corrección en el flujo de verificación y lectura de tokens JWT en el backend.
4.  **Enlaces Simbólicos en Windows:** Activación del *Modo Desarrollador* en el sistema operativo para permitir la compilación exitosa de los plugins de Flutter Web.

---

## Cómo ejecutar el proyecto localmente

### 1. Levantar el Backend
```bash
cd backend
python -m uvicorn app.main:app --reload

### 2. Ejecutar el simulador de sensores
python sensor_emitte.py

#### 3. Ejecutar la web (flutter)
cd mobile
flutter run -d chrome --web-browser-flag "--disable-web-security"
