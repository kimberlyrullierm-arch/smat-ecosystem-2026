#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/types.h>
int main() {
    pid_t mipid, padrepid;
    // Obtener información del PCB a través de System Calls
    mipid = getpid();
    padrepid = getppid();
    printf("=== Información del Proceso ===\n");
    printf("Mi PID es: %d\n", mipid);
    printf("El PID de mi padre es: %d\n", padrepid);
    printf("===============================\n\n");
    printf("Estado: RUNNING (Ejecutándose en CPU)\n");
    printf("Ahora entraré en estado WAITING (Bloqueado) por 10 segundos...\n");
    // El proceso pasa a estado 'Waiting' o 'Sleeping'
    sleep(10);
    printf("\nEstado: RUNNING de nuevo.\n");
    printf("Presiona ENTER para terminar el proceso y pasar a TERMINATED...");
    getchar();
    return 0;
}