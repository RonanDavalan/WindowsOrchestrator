# Windows Orchestrator

[🇫🇷 Francés](README-fr-FR.md) | [🇩🇪 Alemán](README-de-DE.md) | [🇪🇸 Español](README-es-ES.md) | [🇮🇳 Hindi](README-hi-IN.md) | [🇯🇵 Japonés](README-ja-JP.md) | [🇷🇺 Ruso](README-ru-RU.md) | [🇨🇳 Chino](README-zh-CN.md) | [🇸🇦 Árabe](README-ar-SA.md) | [🇧🇩 Bengalí](README-bn-BD.md) | [🇮🇩 Indonesio](README-id-ID.md)

**Su piloto automático para estaciones de trabajo Windows dedicadas. Configure una vez y deje que el sistema se gestione de forma fiable.**

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 ¡Visite la página de inicio oficial para un recorrido completo!</strong></a>
</p>

![Licencia](https://img.shields.io/badge/Licencia-GPLv3-blue.svg)![Versión de PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)![Estado](https://img.shields.io/badge/Status-Operativo-brightgreen.svg)![SO](https://img.shields.io/badge/OS-Windows_10_|_11-informational)![Soporte](https://img.shields.io/badge/Support-11_Idiomas-orange.svg)![Contribuciones](https://img.shields.io/badge/Contributions-Bienvenidas-brightgreen.svg)

---

## Nuestra Misión

Imagine una estación de trabajo Windows perfectamente fiable y autónoma. Una máquina que configura una vez para su misión y de la que luego puede olvidarse. Un sistema que garantiza que su aplicación permanezca **permanentemente operativa**, sin interrupciones.

Este es el objetivo que **Windows Orchestrator** le ayuda a lograr. El desafío es que un PC con Windows estándar no está diseñado de forma nativa para esta resistencia. Está diseñado para la interacción humana: se suspende, instala actualizaciones cuando lo considera oportuno y no reinicia automáticamente una aplicación después de un reinicio.

**Windows Orchestrator** es la solución: un conjunto de scripts que actúa como un supervisor inteligente y permanente. Transforma cualquier PC en un autómata fiable, asegurando que su aplicación crítica esté siempre operativa, sin intervención manual.



Nos enfrentamos no a uno, sino a dos tipos de fallos sistémicos:

#### 1. El fallo abrupto: La interrupción inesperada

El escenario es simple: una máquina configurada para acceso remoto y un corte de energía nocturno. Incluso con una BIOS configurada para el reinicio automático, la misión falla. Windows se reinicia pero permanece en la pantalla de inicio de sesión; la aplicación crítica no se vuelve a iniciar, la sesión no se abre. El sistema es inaccesible.

#### 2. La degradación lenta: Inestabilidad a largo plazo

Aún más insidioso es el comportamiento de Windows con el tiempo. Diseñado como un SO interactivo, no está optimizado para procesos que se ejecutan sin interrupción. Gradualmente, aparecen fugas de memoria y degradación del rendimiento, lo que hace que el sistema sea inestable y requiera un reinicio manual.

### La respuesta: Una capa de fiabilidad nativa

Ante estos desafíos, las utilidades de terceros resultaron insuficientes. Por lo tanto, tomamos la decisión de **arquitectar nuestra propia capa de resiliencia del sistema.**

`Windows Orchestrator` actúa como un piloto automático que toma el control del SO para:

- **Garantizar la recuperación automática:** Después de un fallo, garantiza la apertura de la sesión y el reinicio de su aplicación principal.
- **Garantizar el mantenimiento preventivo:** Le permite programar un reinicio diario controlado con la ejecución de scripts personalizados de antemano.
- **Proteger la aplicación** de interrupciones inoportunas de Windows (actualizaciones, modo de suspensión...).

`Windows Orchestrator` es la herramienta esencial para cualquiera que necesite que una estación de trabajo Windows permanezca **fiable, estable y operativa sin supervisión continua.**

---

## Casos de uso típicos

*   **Señalización digital:** Asegúrese de que el software de señalización funcione 24/7 en una pantalla pública.
*   **Servidores domésticos e IoT:** Controle un servidor Plex, una puerta de enlace de Home Assistant o un objeto conectado desde un PC con Windows.
*   **Estaciones de supervisión:** Mantenga una aplicación de supervisión (cámaras, registros de red) siempre activa.
*   **Kioscos interactivos:** Asegúrese de que la aplicación del quiosco se reinicie automáticamente después de cada reinicio.
*   **Automatización ligera:** Ejecute scripts o procesos continuamente para tareas de minería de datos o pruebas.

---

## Características clave

*   **Asistente de configuración gráfica:** No es necesario editar archivos para la configuración básica.
*   **Soporte multilingüe completo:** Interfaz y registros disponibles en 11 idiomas, con detección automática del idioma del sistema.
*   **Administración de energía:** Deshabilite la suspensión de la máquina, la suspensión de la pantalla y el inicio rápido de Windows para una máxima estabilidad.
*   **Inicio de sesión automático (Auto-Login):** Administra el inicio de sesión automático, incluso en sinergia con la herramienta **Sysinternals AutoLogon** para una gestión segura de contraseñas.
*   **Control de actualizaciones de Windows:** Evite que las actualizaciones y los reinicios forzados interrumpan su aplicación.
*   **Administrador de procesos:** Inicia, supervisa y reinicia automáticamente su aplicación principal con cada sesión.
*   **Reinicio diario programado:** Programe un reinicio diario para mantener la frescura del sistema.
*   **Acción previa al reinicio:** Ejecute un script personalizado (copia de seguridad, limpieza...) antes del reinicio programado.
*   **Registro detallado:** Todas las acciones se registran en archivos de registro para un diagnóstico fácil.
*   **Notificaciones (Opcional):** Envíe informes de estado a través de Gotify.

---

## Público objetivo y mejores prácticas

Este proyecto está diseñado para convertir un PC en un autómata fiable, ideal para casos de uso en los que la máquina está dedicada a una única aplicación (servidor para un dispositivo IoT, señalización digital, estación de monitoreo, etc.). No se recomienda para un ordenador de oficina de uso general o diario.

*   **Actualizaciones importantes de Windows:** Para actualizaciones significativas (por ejemplo, la actualización de Windows 10 a 11), el procedimiento más seguro es **desinstalar** Windows Orchestrator antes de la actualización y luego **volver a instalarlo** después.
*   **Entornos corporativos:** Si su equipo se encuentra en un dominio corporativo administrado por objetos de directiva de grupo (GPO), consulte con su departamento de TI para asegurarse de que las modificaciones realizadas por este script no entren en conflicto con las políticas de su organización.

---

## Instalación y primeros pasos

**Nota sobre el idioma:** Los scripts de inicio (`1_install.bat` y `2_uninstall.bat`) muestran sus instrucciones en **inglés**. Esto es normal. Estos archivos actúan como simples lanzadores. Tan pronto como el asistente gráfico o los scripts de PowerShell tomen el control, la interfaz se adaptará automáticamente al idioma de su sistema operativo.

Configurar **Windows Orchestrator** es un proceso simple y guiado.

1.  **Descargue** o clone el proyecto en el equipo a configurar.
2.  Ejecute `1_install.bat`. El script le guiará a través de dos pasos:
    *   **Paso 1: Configuración a través del asistente gráfico.**
        Ajuste las opciones según sus necesidades. Las más importantes suelen ser el nombre de usuario para el inicio de sesión automático y la aplicación a iniciar. Haga clic en `Guardar` para guardar.
        
        ![Asistente de configuración](assets/screenshot-wizard.png)
        
    *   **Paso 2: Instalación de tareas del sistema.**
        El script solicitará confirmación para continuar. Se abrirá una ventana de seguridad de Windows (UAC). **Debe aceptarla** para permitir que el script cree las tareas programadas necesarias.
3.  ¡Eso es todo! En el próximo reinicio, sus configuraciones se aplicarán.

---

## Configuración
Puede ajustar la configuración en cualquier momento de dos maneras:

### 1. Asistente gráfico (método simple)
Vuelva a ejecutar `1_install.bat` para volver a abrir la interfaz de configuración. Modifique su configuración y guarde.

### 2. Archivo `config.ini` (método avanzado)
Abra `config.ini` con un editor de texto para un control granular.

#### Nota importante sobre el inicio de sesión automático y las contraseñas
Por razones de seguridad, **Windows Orchestrator nunca gestiona ni almacena contraseñas en texto sin formato.** A continuación, se explica cómo configurar el inicio de sesión automático de forma eficaz y segura:

*   **Escenario 1: La cuenta de usuario no tiene contraseña.**
    Simplemente ingrese el nombre de usuario en el asistente gráfico o en `AutoLoginUsername` en el archivo `config.ini`.

*   **Escenario 2: La cuenta de usuario tiene una contraseña (método recomendado).**
    1.  Descargue la herramienta oficial **[Sysinternals AutoLogon](https://download.sysinternals.com/files/AutoLogon.zip)** de Microsoft (enlace de descarga directa).
    2.  Inicie AutoLogon e ingrese el nombre de usuario, el dominio y la contraseña. Esta herramienta almacenará la contraseña de forma segura en el Registro.
    3.  En la configuración de **Windows Orchestrator**, ahora puede dejar el campo `AutoLoginUsername` vacío (el script detectará el usuario configurado por AutoLogon leyendo la clave de Registro correspondiente) o rellenarlo para asegurarse. Nuestro script se asegurará de que la clave de Registro `AutoAdminLogon` esté correctamente habilitada para finalizar la configuración.

#### Configuración avanzada: `PreRebootActionCommand`
Esta potente función le permite ejecutar un script antes del reinicio diario. La ruta puede ser:
- **Absoluta:** `C:\Scripts\my_backup.bat`
- **Relativa al proyecto:** `PreReboot.bat` (el script buscará este archivo en la raíz del proyecto).
- **Usando `%USERPROFILE%`:** `%USERPROFILE%\Desktop\cleanup.ps1` (el script reemplazará inteligentemente `%USERPROFILE%` con la ruta al perfil del usuario de inicio de sesión automático).

---

## Estructura del proyecto
```
WindowsOrchestrator/
├── 1_install.bat                # Punto de entrada para la instalación y configuración
├── 2_uninstall.bat              # Punto de entrada para la desinstalación
├── config.ini                   # Archivo de configuración central
├── config_systeme.ps1           # Script principal para la configuración de la máquina (se ejecuta al inicio)
├── config_utilisateur.ps1       # Script principal para la gestión de procesos de usuario (se ejecuta al iniciar sesión)
├── LaunchApp.bat                # (Ejemplo) Lanzador portátil para su aplicación principal
├── PreReboot.bat                # Script de ejemplo para la acción previa al reinicio
├── Logs/                        # (Creado automáticamente) Contiene archivos de registro
├── i18n/                        # Contiene todos los archivos de traducción
│   ├── en-US/strings.psd1
│   └── ... (otros idiomas)
└── management/
    ├── defaults/default_config.ini # Plantilla de configuración inicial
    ├── tools/                   # Herramientas de diagnóstico
    │   └── Find-WindowInfo.ps1
    ├── firstconfig.ps1          # El código del asistente de configuración gráfica
    ├── install.ps1              # El script técnico para la instalación de tareas
    └── uninstall.ps1            # El script técnico para la eliminación de tareas
```

---

## Operación detallada
El núcleo de **Windows Orchestrator** se basa en el Programador de tareas de Windows:

1.  **Al iniciar Windows**
    *   La tarea `WindowsOrchestrator_SystemStartup` se ejecuta con privilegios `SYSTEM`.
    *   El script `config_systeme.ps1` lee `config.ini` y aplica todas las configuraciones de la máquina. También gestiona la creación/actualización de tareas de reinicio.

2.  **Al iniciar sesión el usuario**
    *   La tarea `WindowsOrchestrator_UserLogon` se ejecuta.
    *   El script `config_utilisateur.ps1` lee la sección `[Process]` de `config.ini` y se asegura de que su aplicación principal se inicie correctamente. Si ya se estaba ejecutando, primero se detiene y luego se reinicia limpiamente.

3.  **Diariamente (si está configurado)**
    *   La tarea `WindowsOrchestrator_PreRebootAction` ejecuta su script de copia de seguridad/limpieza.
    *   Unos minutos más tarde, la tarea `WindowsOrchestrator_ScheduledReboot` reinicia el equipo.

---

### Herramientas de diagnóstico y desarrollo

El proyecto incluye scripts útiles para ayudarle a configurar y mantener el proyecto.

*   **`management/tools/Find-WindowInfo.ps1`**: Si no conoce el título exacto de la ventana de una aplicación (por ejemplo, para configurarla en `Close-AppByTitle.ps1`), ejecute este script. Listará todas las ventanas visibles y sus nombres de proceso, lo que le ayudará a encontrar la información precisa.
*   **`Fix-Encoding.ps1`**: Si modifica los scripts, esta herramienta garantiza que se guarden con la codificación correcta (UTF-8 con BOM) para una compatibilidad perfecta con PowerShell 5.1 y los caracteres internacionales.

---

## Registro
Para facilitar la resolución de problemas, todo se registra.
*   **Ubicación:** En la subcarpeta `Logs/`.
*   **Archivos:** `config_systeme_ps_log.txt` y `config_utilisateur_log.txt`.
*   **Rotación:** Los registros antiguos se archivan automáticamente para evitar que se vuelvan demasiado grandes.

---

## Desinstalación
Para eliminar el sistema:
1.  Ejecute `2_uninstall.bat`.
2.  **Acepte la solicitud de privilegios (UAC)**.
3.  El script eliminará limpiamente todas las tareas programadas y restaurará la configuración principal del sistema.

**Nota sobre la reversibilidad:** La desinstalación no solo elimina las tareas programadas. También restaura la configuración principal del sistema a su estado predeterminado para proporcionarle un sistema limpio:
*   Las actualizaciones de Windows se vuelven a habilitar.
*   El inicio rápido se vuelve a habilitar.
*   Se elimina la política que bloquea OneDrive.
*   El script ofrecerá deshabilitar el inicio de sesión automático.

Su sistema vuelve así a ser una estación de trabajo estándar, sin modificaciones residuales.

---

## Licencia y contribuciones
Este proyecto se distribuye bajo la licencia **GPLv3**. El texto completo está disponible en el archivo `LICENSE`.

Las contribuciones, ya sea en forma de informes de errores, sugerencias de mejora o solicitudes de extracción, son bienvenidas.