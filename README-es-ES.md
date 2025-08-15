# WindowsAutoConfig ⚙️

[🇫🇷 Français](README-fr-FR.md) | [🇺🇸 English](README.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md)

**Su piloto automático para estaciones de trabajo Windows dedicadas. Configure una vez y deje que el sistema se autogestione con total fiabilidad.**

![Licencia](https://img.shields.io/badge/Licence-GPLv3-blue.svg)![Versión PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)![Estado](https://img.shields.io/badge/Statut-Opérationnel-brightgreen.svg)![SO](https://img.shields.io/badge/OS-Windows_10_|_11-informational)![Soporte](https://img.shields.io/badge/Support-11_Langues-orange.svg)![Contribuciones](https://img.shields.io/badge/Contributions-Bienvenidas-brightgreen.svg)

---

## 🎯 Nuestra Misión

Imagine un puesto de trabajo Windows perfectamente fiable y autónomo. Una máquina que configura una sola vez para su misión —ya sea pilotar un objeto conectado, animar un panel de visualización o servir de puesto de supervisión— y de la que luego puede olvidarse. Un sistema que asegura que su aplicación permanezca **operativa permanentemente**, sin interrupción.

Este es el objetivo que **WindowsAutoConfig** le ayuda a alcanzar. El desafío es que un PC con Windows estándar no está diseñado de forma nativa para esta resistencia. Está pensado para la interacción humana: se pone en suspensión para ahorrar energía, instala actualizaciones cuando lo considera oportuno y no reinicia automáticamente una aplicación después de un reinicio.

**WindowsAutoConfig** es la solución: un conjunto de scripts que actúa como un supervisor inteligente y permanente. Transforma cualquier PC en un autómata fiable, garantizando que su aplicación crítica esté siempre operativa, sin intervención manual.

### Más allá de la interfaz: control directo del sistema

WindowsAutoConfig actúa como un panel de control avanzado, haciendo accesibles configuraciones potentes que no están disponibles o son difíciles de gestionar a través de la interfaz estándar de Windows.

*   **Control Total sobre Windows Update:** En lugar de simplemente "pausar" las actualizaciones, el script modifica las políticas del sistema para detener el mecanismo automático, devolviéndole el control sobre cuándo se instalan las actualizaciones.
*   **Configuración de Energía Fiable:** El script no solo establece la suspensión en "Nunca"; se asegura de que esta configuración se vuelva a aplicar en cada arranque, haciendo que su configuración sea resistente a cambios no deseados.
*   **Acceso a Configuraciones de Nivel de Administrador:** Funciones como la desactivación de OneDrive a través de una política del sistema son acciones que generalmente están ocultas en el Editor de Políticas de Grupo (no disponible en Windows Home). Este script las hace accesibles para todos.

## ✨ Características Clave
*   **Asistente de Configuración Gráfico:** No es necesario editar archivos para los ajustes básicos.
*   **Soporte Multilingüe Completo:** Interfaz y registros disponibles en 11 idiomas, con detección automática del idioma del sistema.
*   **Gestión de Energía:** Desactive la suspensión de la máquina, de la pantalla y el inicio rápido de Windows para una estabilidad máxima.
*   **Inicio de Sesión Automático (Auto-Login):** Gestiona el inicio de sesión automático, incluyendo la sinergia con la herramienta **Sysinternals AutoLogon** para una gestión segura de la contraseña.
*   **Control de Windows Update:** Evite que las actualizaciones y los reinicios forzados interrumpan su aplicación.
*   **Administrador de Procesos:** Lanza, supervisa y reinicia automáticamente su aplicación principal en cada sesión.
*   **Reinicio Diario Programado:** Programe un reinicio diario para mantener la frescura del sistema.
*   **Acción Pre-Reinicio:** Ejecute un script personalizado (copia de seguridad, limpieza...) antes del reinicio programado.
*   **Registro Detallado:** Todas las acciones se registran en archivos de registro para un diagnóstico fácil.
*   **Notificaciones (Opcional):** Envíe informes de estado a través de Gotify.

---

## 🎯 Público Objetivo y Buenas Prácticas

Este proyecto está diseñado para transformar un PC en un autómata fiable, ideal para casos de uso en los que la máquina está dedicada a una sola aplicación (servidor para un dispositivo IoT, señalización digital, estación de supervisión, etc.). No se recomienda para un ordenador de oficina de uso general.

*   **Actualizaciones Mayores de Windows:** Para actualizaciones importantes (ej: pasar de Windows 10 a 11), el procedimiento más seguro es **desinstalar** WindowsAutoConfig antes de la actualización y luego **reinstalarlo** después.
*   **Entornos Corporativos:** Si su ordenador está en un dominio empresarial gestionado por Directivas de Grupo (GPO), consulte con su departamento de TI para asegurarse de que las modificaciones realizadas por este script no entran en conflicto con las políticas de su organización.

---

## 🚀 Instalación y Primeros Pasos

**Nota sobre el idioma:** Los scripts de inicio (`1_install.bat` y `2_uninstall.bat`) muestran sus instrucciones en **inglés**. Esto es normal. Estos archivos actúan como simples lanzadores. Tan pronto como el asistente gráfico o los scripts de PowerShell tomen el relevo, la interfaz se adaptará automáticamente al idioma de su sistema operativo.

Poner en marcha **WindowsAutoConfig** es un proceso sencillo y guiado.

1.  **Descargue** o clone el proyecto en el equipo a configurar.
2.  Ejecute `1_install.bat`. El script le guiará a través de dos pasos:
    *   **Paso 1: Configuración a través del Asistente Gráfico.**
        Ajuste las opciones según sus necesidades. Las más importantes suelen ser el identificador para el inicio de sesión automático y la aplicación a lanzar. Haga clic en `Guardar` para guardar.
    *   **Paso 2: Instalación de las Tareas del Sistema.**
        El script le pedirá una confirmación para continuar. Se abrirá una ventana de seguridad de Windows (UAC). **Debe aceptarla** para permitir que el script cree las tareas programadas necesarias.
3.  ¡Listo! En el próximo reinicio, sus configuraciones serán aplicadas.

---

## 🔧 Configuración
Puede ajustar los parámetros en cualquier momento de dos maneras:

### 1. Asistente Gráfico (Método simple)
Vuelva a ejecutar `1_install.bat` para abrir de nuevo la interfaz de configuración. Modifique sus ajustes y guarde.

### 2. Archivo `config.ini` (Método avanzado)
Abra `config.ini` con un editor de texto para un control granular.

#### Nota Importante sobre el Auto-Login y las Contraseñas
Por razones de seguridad, **WindowsAutoConfig nunca gestiona ni almacena las contraseñas en texto claro.** A continuación, se explica cómo configurar el inicio de sesión automático de manera eficiente y segura:

*   **Escenario 1: La cuenta de usuario no tiene contraseña.**
    Simplemente indique el nombre de usuario en el asistente gráfico o en `AutoLoginUsername` del archivo `config.ini`.

*   **Escenario 2: La cuenta de usuario tiene una contraseña (Método recomendado).**
    1.  Descargue la herramienta oficial **[Sysinternals AutoLogon](https://download.sysinternals.com/files/AutoLogon.zip)** de Microsoft (enlace de descarga directa).
    2.  Lance AutoLogon e introduzca el nombre de usuario, el dominio y la contraseña. Esta herramienta almacenará la contraseña de forma segura en el Registro.
    3.  En la configuración de **WindowsAutoConfig**, ahora puede dejar el campo `AutoLoginUsername` vacío (el script detectará el usuario configurado por AutoLogon leyendo la clave de Registro correspondiente) o rellenarlo para asegurarse. Nuestro script se asegurará de que la clave de Registro `AutoAdminLogon` esté bien activada para finalizar la configuración.

#### Configuración Avanzada: `PreRebootActionCommand`
Esta potente funcionalidad le permite ejecutar un script antes del reinicio diario. La ruta de acceso puede ser:
- **Absoluta:** `C:\Scripts\mi_backup.bat`
- **Relativa al proyecto:** `PreReboot.bat` (el script buscará este archivo en la raíz del proyecto).
- **Usando `%USERPROFILE%`:** `%USERPROFILE%\Desktop\cleanup.ps1` (el script reemplazará inteligentemente `%USERPROFILE%` por la ruta del perfil del usuario de Auto-Login).

---

## 📂 Estructura del Proyecto
```
WindowsAutoConfig/
├── 1_install.bat                # Punto de entrada para la instalación y configuración
├── 2_uninstall.bat              # Punto de entrada para la desinstalación
├── config.ini                   # Archivo de configuración central
├── config_systeme.ps1           # Script principal para los ajustes de la máquina (se ejecuta al inicio)
├── config_utilisateur.ps1       # Script principal para la gestión del proceso de usuario (se ejecuta al iniciar sesión)
├── LaunchApp.bat                # (Ejemplo) Lanzador portátil para su aplicación principal
├── PreReboot.bat                # Ejemplo de script para la acción pre-reinicio
├── Logs/                        # (Creado automáticamente) Contiene los archivos de registro
├── i18n/                        # Contiene todos los archivos de traducción
│   ├── es-ES/strings.psd1
│   └── ... (otros idiomas)
└── management/
    ├── defaults/default_config.ini # Plantilla de configuración inicial
    ├── tools/                   # Herramientas de diagnóstico
    │   └── Find-WindowInfo.ps1
    ├── firstconfig.ps1          # El código del asistente de configuración gráfico
    ├── install.ps1              # El script técnico de instalación de las tareas
    └── uninstall.ps1            # El script técnico de eliminación de las tareas
```

---

## ⚙️ Funcionamiento Detallado
El núcleo de **WindowsAutoConfig** se basa en el Programador de Tareas de Windows:

1.  **Al Iniciar Windows**
    *   La tarea `WindowsAutoConfig_SystemStartup` se ejecuta con los derechos `SISTEMA`.
    *   El script `config_systeme.ps1` lee `config.ini` y aplica todas las configuraciones de la máquina. También gestiona la creación/actualización de las tareas de reinicio.

2.  **Al Iniciar Sesión de Usuario**
    *   La tarea `WindowsAutoConfig_UserLogon` se ejecuta.
    *   El script `config_utilisateur.ps1` lee la sección `[Process]` de `config.ini` y se asegura de que su aplicación principal esté bien lanzada. Si ya estaba en ejecución, primero se detiene y luego se reinicia de forma limpia.

3.  **Diariamente (Si está configurado)**
    *   La tarea `WindowsAutoConfig_PreRebootAction` ejecuta su script de copia de seguridad/limpieza.
    *   Unos minutos más tarde, la tarea `WindowsAutoConfig_ScheduledReboot` reinicia el ordenador.

---

### 🛠️ Herramientas de Diagnóstico y Desarrollo

El proyecto incluye scripts útiles para ayudarle a configurar y mantener el proyecto.

*   **`management/tools/Find-WindowInfo.ps1`**: Si no conoce el título exacto de la ventana de una aplicación (para configurarlo en `Close-AppByTitle.ps1`, por ejemplo), ejecute este script. Listará todas las ventanas visibles y el nombre de su proceso, ayudándole a encontrar la información precisa.
*   **`Fix-Encoding.ps1`**: Si modifica los scripts, esta herramienta se asegura de que se guarden con la codificación correcta (UTF-8 con BOM) para una compatibilidad perfecta con PowerShell 5.1 y los caracteres internacionales.

---

## 📄 Registro (Logging)
Para una fácil resolución de problemas, todo se registra.
*   **Ubicación:** En la subcarpeta `Logs/`.
*   **Archivos:** `config_systeme_ps_log.txt` y `config_utilisateur_log.txt`.
*   **Rotación:** Los registros antiguos se archivan automáticamente para evitar que sean demasiado voluminosos.

---

## 🗑️ Desinstalación
Para retirar el sistema:
1.  Ejecute `2_uninstall.bat`.
2.  **Acepte la solicitud de privilegios (UAC)**.
3.  El script eliminará limpiamente todas las tareas programadas y restaurará los principales parámetros del sistema.

**Nota sobre la reversibilidad:** La desinstalación no se limita a eliminar las tareas programadas. También restaura los principales parámetros del sistema a su estado predeterminado para devolverle un sistema limpio:
*   Las actualizaciones de Windows se reactivan.
*   El Inicio Rápido se reactiva.
*   La política de bloqueo de OneDrive se elimina.
*   El script le propondrá desactivar el inicio de sesión automático.

Su sistema vuelve a ser así un puesto de trabajo estándar, sin modificaciones residuales.

---

## ❤️ Licencia y Contribuciones
Este proyecto se distribuye bajo la licencia **GPLv3**. El texto completo está disponible en el archivo `LICENSE`.

Las contribuciones, ya sea en forma de informes de errores, sugerencias de mejora o "pull requests", son bienvenidas.