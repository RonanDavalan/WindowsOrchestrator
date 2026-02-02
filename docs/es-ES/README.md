# WindowsOrchestrator 1.74

<p align="center">
  <img src="https://img.shields.io/badge/Version-v1.74-2ea44f" alt="Version">
  <img src="https://img.shields.io/badge/Licencia-GPLv3-blue.svg" alt="Licencia">
  <img src="https://img.shields.io/badge/Plataforma-Windows_10_|_11-0078D6" alt="SO Soportados">
  <img src="https://img.shields.io/badge/Arquitectura-x86_|_x64_|_ARM64-blueviolet" alt="Arquitectura CPU">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue" alt="Versión PowerShell">
  <img src="https://img.shields.io/badge/Tipo-Aplicación_Portable-orange" alt="Sin Instalación">
</p>

[🇺🇸 English](../../README.md) | [🇫🇷 Français](../fr-FR/README.md) | [🇩🇪 Deutsch](../de-DE/README.md) | **🇪🇸 Español**

## Descripción

**WindowsOrchestrator** es una solución de automatización en PowerShell diseñada para transformar una estación de trabajo Windows estándar en un sistema autónomo ("Kiosk" o "Appliance").

🌐 **Sitio web oficial**: [wo.davalan.fr](https://wo.davalan.fr/es)

Permite configurar, proteger y orquestar el ciclo de vida del sistema operativo. Una vez configurado, asegura que la máquina arranque, inicie sesión y ejecute una aplicación de negocio sin ninguna intervención humana, gestionando al mismo tiempo el mantenimiento diario (copia de seguridad, reinicio).

## Casos de uso y público objetivo

Por defecto, Windows está diseñado para la interacción humana (pantalla de inicio de sesión, actualizaciones, notificaciones). WindowsOrchestrator elimina estas fricciones para usos dedicados:

*   **Señalización Digital**: Pantallas publicitarias, paneles de información, tableros de menús.
*   **Kioscos Interactivos**: Venta de entradas, terminales de pedidos, cajeros automáticos.
*   **PCs Industriales**: Interfaces Hombre-Máquina (HMI), autómatas de control en líneas de producción.
*   **Servidores Windows**: Lanzamiento automático de aplicaciones que requieren una sesión interactiva persistente.

## Filosofía: Un orquestador modular

WindowsOrchestrator no es un script de "endurecimiento" (hardening) rígido. Es una herramienta flexible que se adapta a sus necesidades.

*   **Flexibilidad Total**: No se fuerza ninguna configuración. Puede optar por desactivar el inicio rápido sin tocar Windows Update, o viceversa.
*   **Responsabilidad**: La herramienta aplica estrictamente lo que usted solicita. Está diseñada para entornos controlados donde la estabilidad prevalece sobre las actualizaciones funcionales constantes.
*   **Arquitectura Multi-Contexto**:
    *   **Estándar**: Mantiene la pantalla de inicio de sesión de Windows (Logon UI). Inicia la aplicación una vez que el usuario se conecta manualmente.
    *   **Autologon**: Inicia automáticamente la sesión del usuario y muestra el escritorio.

## Filosofía técnica: Enfoque nativo

El orquestador prioriza la estabilidad y el uso de los mecanismos nativos de Windows para garantizar la perdurabilidad de las configuraciones.

*   **Gestión de energía "en duro"**: Modificación directa de los planes de energía AC/DC a través de `powercfg.exe`. Sin simulación de actividad de ratón/teclado.
*   **Actualizaciones a través de GPO**: Uso de las claves de registro `HKLM:\SOFTWARE\Policies` (método Empresarial) para resistir los mecanismos de autorreparación de Windows Update.
*   **Estabilidad por "Cold Boot"**: Desactivación posible del inicio rápido (`HiberbootEnabled`) para forzar una recarga completa de los controladores y del núcleo en cada reinicio.
*   **Seguridad de las credenciales (LSA)**: En modo Autologon, la contraseña nunca se almacena en texto plano. El orquestador delega el cifrado a la herramienta **Sysinternals Autologon**, que almacena las credenciales en los secretos LSA (Local Security Authority) de Windows.

## Capacidades funcionales

### Gestión de sesión (Autologon)
*   Configuración automatizada del registro Winlogon.
*   Integración de la herramienta oficial Microsoft Sysinternals Autologon.
*   Soporte nativo para arquitecturas x86, AMD64 y ARM64.
*   Descarga y ejecución automatizadas de la herramienta para la configuración de credenciales.

### Lanzamiento automático
*   Uso del **Programador de Tareas** (disparador *AtLogon*) para garantizar el lanzamiento con los privilegios adecuados.
*   **Modos de lanzamiento de consola**:
    *   *Estándar*: Utiliza el terminal por defecto (ej: Windows Terminal).
    *   *Legacy*: Fuerza el uso de `conhost.exe` para la compatibilidad con scripts `.bat` antiguos.
*   Opción para iniciar la aplicación **minimizada** en la barra de tareas.

### Copia de seguridad de datos
*   Módulo de copia de seguridad inteligente ejecutado antes del reinicio.
*   **Lógica diferencial**: Copia solo los archivos modificados en las últimas 24 horas.
*   **Soporte para archivos emparejados**: Ideal para bases de datos (ej: copia simultánea de `.db`, `.db-wal`, `.db-shm`).
*   **Política de retención**: Purga automática de archivos que superan una antigüedad definida (por defecto: 30 días).

#### **Mantenimiento de registros (Recorte de logs)**
*   **Módulo de reducción** : Script autónomo (`reducelog.ps1`) para prevenir la saturación del disco causada por registros de aplicaciones voluminosos.
*   **Recorte inteligente** : Recorta los archivos objetivo para conservar solo las últimas N líneas (configurable).
*   **Soporte de comodines** : Acepta patrones genéricos (ej: `*.log`, `error_*.txt`) para dirigir dinámicamente múltiples archivos.
*   **Integración segura** : Se ejecuta durante la ventana de mantenimiento, con la aplicación cerrada, antes de la copia de seguridad.

### Gestión del entorno del sistema
*   **Windows Update**: Bloqueo del servicio y desactivación del reinicio forzado post-actualización.
*   **Fast Startup**: Desactivación para garantizar reinicios limpios.
*   **Energía**: Desactivación de la suspensión de la máquina (S3/S4) y de la pantalla.
*   **OneDrive**: Tres políticas de gestión (`Block` por GPO, `Close` el proceso, o `Ignore`).

### Planificación de tareas
*   **Cierre de Aplicación**: Envío de comandos de cierre limpio (ej: {ESC}{ESC}x{ENTER} a través de API) a una hora específica.
*   **Reinicio del Sistema**: Reinicio completo planificado diariamente.
*   **Copia de Seguridad**: Tarea independiente, ejecutada en paralelo al cierre.

### Modo Silencioso (Nuevo v1.73)
*   Instalación y desinstalación posibles sin ventanas de consola visibles (`-WindowStyle Hidden`).
*   **Splash Screen**: Interfaz gráfica de espera con barra de progreso para tranquilizar al usuario.
*   **Feedback**: Notificación final mediante un cuadro de diálogo (`MessageBox`) que indica el éxito o el fracaso.

### Internacionalización y Notificaciones
*   **i18n**: Detección automática del idioma del sistema (Soporte nativo: `fr-FR`, `en-US`, `es-ES`, `de-DE`).
*   **Gotify**: Módulo opcional para enviar informes de ejecución (éxito/errores) a un servidor Gotify.

### Nuevas Funcionalidades v1.73

#### Launcher Dinámico
*   **Lanzamiento Basado en Configuración**: Lee `config.ini` para determinar dinámicamente los parámetros de lanzamiento de aplicaciones, modos y rutas sin codificación fija.
*   **Modos de Ejecución Flexibles**: Soporta múltiples estrategias de lanzamiento basadas en configuración, incluyendo inicio minimizado y selección de consola.

#### Seguridad Watchdog
*   **Monitoreo de Procesos**: Monitoreo continuo de procesos de aplicaciones lanzadas para detectar fallos o crashes.
*   **Recuperación Automática**: Tras la detección de terminación de procesos, activa mecanismos de reinicio automático para mantener el tiempo de actividad del sistema.
*   **Verificaciones de Salud**: Verificación periódica de la capacidad de respuesta de la aplicación para prevenir fallos silenciosos.

#### Inteligencia Temporal (Inferencia Automática y Efecto Dominó)
*   **Programación Inteligente**: Analiza patrones de uso y estados del sistema para inferir automáticamente tiempos óptimos para respaldos, reinicios y mantenimiento.
*   **Prevención del Efecto Dominó**: Detecta dependencias en cascada entre operaciones del sistema para evitar conflictos y asegurar ejecución secuencial.
*   **Comportamiento Adaptativo**: Ajusta horarios basados en rendimiento del sistema en tiempo real y necesidades de aplicaciones.

## Procedimiento de despliegue

### Requisitos previos
*   **SO**: Windows 10 o Windows 11 (Todas las ediciones).
*   **Permisos**: Se requieren permisos de Administrador (para modificar HKLM y crear tareas).
*   **PowerShell**: Versión 5.1 o superior.

### Instalación

1.  Descargue y descomprima el archivo del proyecto.
2.  Ejecute el script **`Install.bat`** (acepte la solicitud de elevación de privilegios).
3.  Se abrirá el **Asistente de Configuración** (`firstconfig.ps1`):
    *   Indique la ruta de la aplicación a iniciar.
    *   Defina los horarios del ciclo diario (Cierre / Copia de seguridad / Reinicio).
    *   Active el Autologon si es necesario.
    *   En la pestaña "Avanzado", configure la copia de seguridad y el modo silencioso.
4.  Haga clic en **"Guardar y Cerrar"**.
5.  La instalación automática (`install.ps1`) tomará el relevo:
    *   Creación de las tareas programadas.
    *   *Si Autologon está activado*: Descarga automática de la herramienta Sysinternals y apertura de la ventana de configuración para introducir la contraseña.

> **Nota**: Si se selecciona el modo Autologon con `UseAutologonAssistant=true`, el asistente intentará descargar la herramienta. Si la máquina no tiene internet, un cuadro de diálogo le ofrecerá seleccionar el archivo `Autologon.zip` manualmente.

### Desinstalación

1.  Ejecute el script **`Uninstall.bat`**.
2.  Se ejecutará el script de limpieza (`uninstall.ps1`):
    *   Eliminación de todas las tareas programadas `WindowsOrchestrator-*`.
    *   Restauración de la configuración por defecto de Windows (Windows Update, Fast Startup, OneDrive).
    *   *Si se detecta Autologon*: Inicio de la herramienta Autologon para permitir una desactivación limpia (limpieza de los secretos LSA).
    *   Visualización de un informe de fin de operación.

> **Nota**: Por seguridad, los archivos de configuración (`config.ini`) y los registros (`Logs/`) no se eliminan automáticamente.

## Configuración y observabilidad

### Archivo de Configuración (`config.ini`)
Generado en la raíz del proyecto por el asistente, controla todo el sistema.
*   `[SystemConfig]`: Parámetros vitales (Sesión, FastStartup, WindowsUpdate, OneDrive).
*   `[Process]`: Rutas de la aplicación, argumentos, horarios, supervisión de procesos.
*   `[DatabaseBackup]`: Activación, rutas de origen/destino, retención.
*   `[Installation]`: Comportamiento del instalador (Modo silencioso, URL de Autologon, Reinicio al final de la instalación).
*   `[Logging]`: Parámetros de rotación de registros.
*   `[Gotify]`: Configuración de las notificaciones push.

### Registros (Logging)
El orquestador genera registros detallados para cada operación.
*   **Ubicación**: Carpeta `Logs/` en la raíz del proyecto.
*   **Archivos**:
    *   `config_systeme_ps_log.txt`: Acciones realizadas por el contexto SYSTEM (Arranque, Tareas en segundo plano).
    *   `config_utilisateur_log.txt`: Acciones realizadas en la sesión del usuario (Lanzamiento de la aplicación).
    *   `Invoke-DatabaseBackup_log.txt`: Informe específico de las copias de seguridad.
*   **Rotación**: Conservación de los últimos 7 archivos (configurable) para evitar la saturación del disco.
*   **Fallback**: Si la carpeta `Logs/` es inaccesible, los errores críticos se escriben en `C:\ProgramData\StartupScriptLogs`.

### Tareas programadas creadas
La instalación registra las siguientes tareas en el Programador de Tareas de Windows:
| Nombre de la tarea | Contexto | Disparador | Acción |
| :--- | :--- | :--- | :--- |
| `WindowsOrchestrator-SystemStartup` | SYSTEM | Arranque del sistema | Aplica la configuración del sistema (Energía, Update...) |
| `WindowsOrchestrator-UserLogon` | Usuario | Inicio de sesión | Inicia la aplicación de negocio |
| `WindowsOrchestrator-SystemBackup` | SYSTEM | Hora programada | Realiza la copia de seguridad de los datos |
| `WindowsOrchestrator-SystemScheduledReboot` | SYSTEM | Hora programada | Reinicia el ordenador |
| `WindowsOrchestrator-User-CloseApp` | Usuario | Hora programada | Cierra la aplicación de forma limpia |

## Documentación

Para más información, consulte las guías detalladas:

📘 **[Guía del Usuario](GUIA_DEL_USUARIO.md)**
*Destinado a administradores de sistemas y técnicos de despliegue.*
Contiene los procedimientos paso a paso, las capturas de pantalla del asistente y las guías de solución de problemas.

🛠️ **[Guía del Desarrollador](GUIA_DEL_DESARROLLADOR.md)**
*Destinado a integradores y auditores de seguridad.*
Detalla la arquitectura interna, el análisis del código, los mecanismos de seguridad LSA y la estructura de los módulos.

## Conformidad y seguridad

*   **Licencia**: Este proyecto se distribuye bajo la licencia **GPLv3**. Consulte el archivo `LICENSE` para más detalles.
*   **Dependencias**:
    *   El proyecto es autónomo ("Portable App").
    *   La activación de Autologon descarga la herramienta **Microsoft Sysinternals Autologon** (sujeta a su propia EULA, que el usuario debe aceptar durante la instalación).
*   **Seguridad de los datos**:
    *   WindowsOrchestrator no almacena **ninguna contraseña** en texto plano en sus archivos de configuración.
    *   Los privilegios están compartimentados: el script de usuario no puede modificar la configuración del sistema.

## Contribución y soporte

Este proyecto se desarrolla y comparte en tiempo libre.
*   **Errores**: Si encuentra un error técnico, por favor, infórmelo a través de las **Issues** de GitHub.
*   **Contribuciones**: Las Pull Requests son bienvenidas para mejorar la herramienta.
