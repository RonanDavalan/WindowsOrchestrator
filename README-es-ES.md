# El orquestador de Windows

[🇺🇸 English](README.md) | [🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

El orquestador de Windows es un conjunto de scripts que utiliza las Tareas Programadas de Windows para ejecutar scripts de PowerShell (`.ps1`). Un asistente gráfico (`firstconfig.ps1`) permite al usuario generar un archivo de configuración `config.ini`. Los scripts principales (`config_systeme.ps1`, `config_utilisateur.ps1`) leen este archivo para realizar acciones específicas:
*   Modificación de claves del Registro de Windows.
*   Ejecución de comandos del sistema (`powercfg`, `shutdown`).
*   Gestión de servicios de Windows (cambio del tipo de inicio y detención del servicio `wuauserv`).
*   Inicio o detención de procesos de aplicaciones definidos por el usuario.
*   Envío de solicitudes HTTP POST a un servicio de notificación Gotify mediante el comando `Invoke-RestMethod`.

Los scripts detectan el idioma del sistema operativo del usuario y cargan las cadenas de texto (para los registros, la interfaz gráfica y las notificaciones) desde los archivos `.psd1` ubicados en el directorio `i18n`.

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 ¡Visita la página de inicio oficial para una presentación completa!</strong></a>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Licencia-GPLv3-blue.svg" alt="Licencia">
  <img src="https://img.shields.io/badge/Versión_PowerShell-5.1%2B-blue" alt="Versión PowerShell">
  <img src="https://img.shields.io/badge/Estado-Operativo-brightgreen.svg" alt="Estado">
  <img src="https://img.shields.io/badge/SO-Windows_10_|_11-informational" alt="SO">
  <img src="https://img.shields.io/badge/Soporte-11_Idiomas-orange.svg" alt="Soporte">
  <img src="https://img.shields.io/badge/Contribuciones-Bienvenidas-brightgreen.svg" alt="Contribuciones">
</p>

---

## Acciones de los Scripts

El script `1_install.bat` ejecuta `management\install.ps1`, que crea dos Tareas Programadas principales.
*   La primera, **`WindowsOrchestrator-SystemStartup`**, ejecuta `config_systeme.ps1` al iniciar Windows.
*   La segunda, **`WindowsOrchestrator-UserLogon`**, ejecuta `config_utilisateur.ps1` al iniciar sesión el usuario.

Dependiendo de la configuración del archivo `config.ini`, los scripts realizan las siguientes acciones:

*   **Gestión del inicio de sesión automático:**
    *   `Acción del script:` El script escribe el valor `1` en la clave de Registro `HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\AutoAdminLogon`.
    *   `Acción del usuario:` Para que esta función sea operativa, el usuario debe registrar previamente la contraseña en el Registro. El script no gestiona esta información. La utilidad **Sysinternals AutoLogon** es una herramienta externa que puede realizar esta acción.

*   **Modificación de la configuración de energía:**
    *   Ejecuta los comandos `powercfg /change standby-timeout-ac 0` y `powercfg /change hibernate-timeout-ac 0` para desactivar la suspensión.
    *   Ejecuta el comando `powercfg /change monitor-timeout-ac 0` para desactivar el apagado de la pantalla.
    *   Escribe el valor `0` en la clave de Registro `HiberbootEnabled` para desactivar el Inicio Rápido.

*   **Gestión de Windows Update:**
    *   Escribe el valor `1` en las claves de Registro `NoAutoUpdate` y `NoAutoRebootWithLoggedOnUsers`.
    *   Cambia el tipo de inicio del servicio de Windows `wuauserv` a `Disabled` y ejecuta el comando `Stop-Service` sobre él.

*   **Programación de un reinicio diario:**
    *   Crea una Tarea Programada llamada `WindowsOrchestrator-SystemScheduledReboot` que ejecuta `shutdown.exe /r /f /t 60` a la hora definida.
    *   Crea una Tarea Programada llamada `WindowsOrchestrator-SystemPreRebootAction` que ejecuta un comando definido por el usuario antes del reinicio.

*   **Registro de acciones:**
    *   Escribe líneas con marca de tiempo en archivos `.txt` ubicados en la carpeta `Logs`.
    *   Una función `Rotate-LogFile` renombra y archiva los archivos de registro existentes. El número de archivos a conservar se define mediante las claves `MaxSystemLogsToKeep` y `MaxUserLogsToKeep` en `config.ini`.

*   **Envío de notificaciones Gotify:**
    *   Si la clave `EnableGotify` está en `true` en `config.ini`, los scripts envían una solicitud HTTP POST a la URL especificada.
    *   La solicitud contiene una carga útil JSON con un título y un mensaje. El mensaje es una lista de las acciones realizadas y los errores encontrados.

## Requisitos Previos

- **Sistema operativo**: Windows 10 o Windows 11. El código fuente contiene la directiva `#Requires -Version 5.1` para los scripts de PowerShell.
- **Permisos**: El usuario debe aceptar las solicitudes de elevación de privilegios (UAC) al ejecutar `1_install.bat` y `2_uninstall.bat`. Esta acción es necesaria para permitir que los scripts creen tareas programadas y modifiquen las claves de Registro a nivel de sistema.
- **Inicio de Sesión Automático (Auto-Login)**: Si el usuario activa esta opción, debe utilizar una herramienta externa como **Microsoft Sysinternals AutoLogon** para registrar su contraseña en el Registro.

## Instalación y Primera Configuración

El usuario ejecuta el archivo **`1_install.bat`**.

1.  **Configuración (`firstconfig.ps1`)**
    *   El script `management\firstconfig.ps1` se ejecuta y muestra una interfaz gráfica.
    *   Si el archivo `config.ini` no existe, se crea a partir de la plantilla `management\defaults\default_config.ini`.
    *   Si ya existe, el script pregunta al usuario si desea reemplazarlo con la plantilla.
    *   El usuario introduce los parámetros. Al hacer clic en "Guardar y Cerrar", el script escribe los valores en `config.ini`.

2.  **Instalación de las Tareas (`install.ps1`)**
    *   Tras cerrar el asistente, `1_install.bat` ejecuta `management\install.ps1` solicitando elevación de privilegios.
    *   El script `install.ps1` crea las dos Tareas Programadas:
        *   **`WindowsOrchestrator-SystemStartup`**: Ejecuta `config_systeme.ps1` al iniciar Windows con la cuenta `NT AUTHORITY\SYSTEM`.
        *   **`WindowsOrchestrator-UserLogon`**: Ejecuta `config_utilisateur.ps1` al iniciar sesión el usuario que lanzó la instalación.
    *   Para aplicar la configuración sin esperar un reinicio, `install.ps1` ejecuta `config_systeme.ps1` y luego `config_utilisateur.ps1` una sola vez al final del proceso.

## Uso y Configuración Posterior a la Instalación

Cualquier modificación de la configuración después de la instalación se realiza a través del archivo `config.ini`.

### 1. Modificación Manual del archivo `config.ini`

*   **Acción del usuario:** El usuario abre el archivo `config.ini` con un editor de texto y modifica los valores deseados.
*   **Acción de los scripts:**
    *   Las modificaciones de la sección `[SystemConfig]` son leídas y aplicadas por `config_systeme.ps1` **en el próximo reinicio del ordenador**.
    *   Las modificaciones de la sección `[Process]` son leídas y aplicadas por `config_utilisateur.ps1` **en el próximo inicio de sesión del usuario**.

### 2. Uso del Asistente Gráfico

*   **Acción del usuario:** El usuario ejecuta de nuevo `1_install.bat`. La interfaz gráfica se abre, pre-rellenada con los valores actuales de `config.ini`. El usuario modifica los parámetros y hace clic en "Guardar y Cerrar".
*   **Acción del script:** El script `firstconfig.ps1` escribe los nuevos valores en `config.ini`.
*   **Contexto de uso:** Tras cerrar el asistente, la línea de comandos propone continuar con la instalación de las tareas. El usuario puede cerrar esta ventana para actualizar únicamente la configuración.

## Desinstalación

El usuario ejecuta el archivo **`2_uninstall.bat`**. Este último ejecuta `management\uninstall.ps1` tras una solicitud de elevación de privilegios (UAC).

El script `uninstall.ps1` realiza las siguientes acciones:

1.  **Inicio de Sesión Automático:** El script muestra un mensaje preguntando si se debe desactivar el inicio de sesión automático. Si el usuario responde `s` (sí), el script escribe el valor `0` en la clave de Registro `AutoAdminLogon`.
2.  **Restauración de ciertos parámetros del sistema:**
    *   **Actualizaciones:** Establece el valor de Registro `NoAutoUpdate` en `0` y configura el tipo de inicio del servicio `wuauserv` en `Automatic`.
    *   **Inicio Rápido:** Establece el valor de Registro `HiberbootEnabled` en `1`.
    *   **OneDrive:** Elimina el valor de Registro `DisableFileSyncNGSC`.
3.  **Eliminación de las Tareas Programadas:** El script busca y elimina las tareas `WindowsOrchestrator-SystemStartup`, `WindowsOrchestrator-UserLogon`, `WindowsOrchestrator-SystemScheduledReboot`, y `WindowsOrchestrator-SystemPreRebootAction`.

### Nota sobre la Restauración de la Configuración

**El script de desinstalación no restaura la configuración de energía** que fue modificada por el comando `powercfg`.
*   **Consecuencia para el usuario:** Si la suspensión del equipo o de la pantalla fue desactivada por los scripts, permanecerá así después de la desinstalación.
*   **Acción requerida por el usuario:** Para reactivar la suspensión, el usuario debe reconfigurar manualmente estas opciones en la "Configuración de energía y suspensión" de Windows.

El proceso de desinstalación **no elimina ningún archivo**. El directorio del proyecto y su contenido permanecen en el disco.

## Estructura del Proyecto

```
WindowsOrchestrator/
├── 1_install.bat                # Ejecuta la configuración gráfica y luego la instalación de las tareas.
├── 2_uninstall.bat              # Ejecuta el script de desinstalación.
├── Close-App.bat                # Ejecuta el script de PowerShell Close-AppByTitle.ps1.
├── Close-AppByTitle.ps1         # Script que encuentra una ventana por su título y le envía una secuencia de teclas.
├── config.ini                   # Archivo de configuración leído por los scripts principales.
├── config_systeme.ps1           # Script para la configuración del sistema, ejecutado al inicio.
├── config_utilisateur.ps1       # Script para la gestión de procesos, ejecutado al iniciar sesión.
├── Fix-Encoding.ps1             # Herramienta para convertir los archivos de script a codificación UTF-8 con BOM.
├── LaunchApp.bat                # Script batch de ejemplo para lanzar una aplicación externa.
├── List-VisibleWindows.ps1      # Utilidad que lista las ventanas visibles y sus procesos.
├── i18n/
│   ├── en-US/
│   │   └── strings.psd1         # Archivo de cadenas de texto para inglés.
│   └── ... (otros idiomas)
└── management/
    ├── firstconfig.ps1          # Muestra el asistente de configuración gráfico.
    ├── install.ps1              # Crea las tareas programadas y ejecuta los scripts una vez.
    ├── uninstall.ps1            # Elimina las tareas y restaura la configuración del sistema.
    └── defaults/
        └── default_config.ini   # Plantilla para crear el archivo config.ini inicial.
```

## Principios Técnicos

*   **Comandos Nativos**: El proyecto utiliza exclusivamente comandos nativos de Windows y PowerShell. No es necesario instalar ninguna dependencia externa.
*   **Bibliotecas del Sistema**: Las interacciones avanzadas con el sistema se basan únicamente en bibliotecas integradas en Windows (ej: `user32.dll`).

## Descripción de los Archivos Clave

### `1_install.bat`
Este archivo batch es el punto de entrada del proceso de instalación. Ejecuta `management\firstconfig.ps1` para la configuración, y luego ejecuta `management\install.ps1` con privilegios elevados.

### `2_uninstall.bat`
Este archivo batch es el punto de entrada de la desinstalación. Ejecuta `management\uninstall.ps1` con privilegios elevados.

### `config.ini`
Es el archivo de configuración central. Contiene las instrucciones (claves y valores) que son leídas por los scripts `config_systeme.ps1` y `config_utilisateur.ps1` para determinar qué acciones realizar.

### `config_systeme.ps1`
Ejecutado al inicio del ordenador por una Tarea Programada, este script lee la sección `[SystemConfig]` del archivo `config.ini`. Aplica la configuración modificando el Registro de Windows, ejecutando comandos del sistema (`powercfg`), y gestionando servicios (`wuauserv`).

### `config_utilisateur.ps1`
Ejecutado al iniciar sesión el usuario por una Tarea Programada, este script lee la sección `[Process]` del archivo `config.ini`. Su función es detener cualquier instancia existente del proceso objetivo, y luego reiniciarlo usando los parámetros proporcionados.

### `management\firstconfig.ps1`
Este script de PowerShell muestra la interfaz gráfica que permite leer y escribir los parámetros en el archivo `config.ini`.

### `management\install.ps1`
Este script contiene la lógica para crear las Tareas Programadas `WindowsOrchestrator-SystemStartup` y `WindowsOrchestrator-UserLogon`.

### `management\uninstall.ps1`
Este script contiene la lógica para eliminar las Tareas Programadas y restaurar las claves de Registro del sistema a sus valores por defecto.

## Gestión mediante Tareas Programadas

La automatización se basa en el Programador de Tareas de Windows (`taskschd.msc`). Las siguientes tareas son creadas por los scripts:

*   **`WindowsOrchestrator-SystemStartup`**: Se activa al iniciar el PC y ejecuta `config_systeme.ps1`.
*   **`WindowsOrchestrator-UserLogon`**: Se activa al iniciar sesión y ejecuta `config_utilisateur.ps1`.
*   **`WindowsOrchestrator-SystemScheduledReboot`**: Creada por `config_systeme.ps1` si `ScheduledRebootTime` está definido en `config.ini`.
*   **`WindowsOrchestrator-SystemPreRebootAction`**: Creada por `config_systeme.ps1` si `PreRebootActionCommand` está definido en `config.ini`.

**Importante**: Eliminar estas tareas manualmente a través del programador de tareas detiene la automatización pero no restaura la configuración del sistema. El usuario debe utilizar imperativamente `2_uninstall.bat` para una desinstalación completa y controlada.

## Licencia y Contribuciones

Este proyecto se distribuye bajo la licencia **GPLv3**. El texto completo está disponible en el archivo `LICENSE`.

Las contribuciones, ya sean informes de errores, sugerencias de mejora o solicitudes de extracción (pull requests), son bienvenidas.