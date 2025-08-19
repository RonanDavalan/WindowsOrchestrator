# WindowsAutoConfig ⚙️

[🇺🇸 English](README.md) | [🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

**Su piloto automático para estaciones de trabajo Windows dedicadas. Configure una vez y deje que el sistema se autogestione con total fiabilidad.**

🔗 **[Descubrir el proyecto](https://wac.davalan.fr/)**

![Licencia](https://img.shields.io/badge/Licence-GPLv3-blue.svg)![Versión PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)![Estado](https://img.shields.io/badge/Status-Operational-brightgreen.svg)![SO](https://img.shields.io/badge/OS-Windows_10_|_11-informational)![Soporte](https://img.shields.io/badge/Support-11_Languages-orange.svg)![Contribuciones](https://img.shields.io/badge/Contributions-Welcome-brightgreen.svg)


        


---

## ▸ Nuestra Misión

Imagine una estación de trabajo Windows perfectamente fiable y autónoma. Una máquina que configura una vez para su misión y de la que luego puede olvidarse. Un sistema que garantiza que su aplicación permanezca **permanentemente operativa**, sin interrupciones.

Este es el objetivo que **WindowsAutoConfig** le ayuda a alcanzar. El desafío es que un PC con Windows estándar no está diseñado de forma nativa para esta resistencia. Está diseñado para la interacción humana: se suspende, instala actualizaciones cuando lo considera oportuno y no reinicia automáticamente una aplicación después de un reinicio.

**WindowsAutoConfig** es la solución: un conjunto de scripts que actúa como un supervisor inteligente y permanente. Transforma cualquier PC en un autómata fiable, garantizando que su aplicación crítica esté siempre operativa, sin intervención manual.

### ¿Por qué se creó `WindowsAutoConfig`? La historia de una necesidad real.

`WindowsAutoConfig` es una solución de ingeniería, nacida de la necesidad de garantizar la **continuidad operativa** en un sistema operativo de escritorio. **Desarrollado como parte de nuestra solución de IA local AllSys, ahora es una herramienta de código abierto independiente que se puede utilizar para cualquier aplicación.**

Nos enfrentamos no a uno, sino a dos tipos de fallos sistémicos:

#### 1. El fallo brusco: el apagón inesperado

El escenario es simple: una máquina configurada para acceso remoto y un corte de energía nocturno. Incluso con un BIOS configurado para un reinicio automático, la misión falla. Windows se reinicia pero permanece en la pantalla de inicio de sesión; la aplicación crítica no se vuelve a iniciar, la sesión no se abre. El sistema es inaccesible.

#### 2. La degradación lenta: la inestabilidad a largo plazo

Incluso más insidioso es el comportamiento de Windows a lo largo del tiempo. Diseñado como un sistema operativo interactivo, no está optimizado para procesos que se ejecutan sin interrupción. Gradualmente, aparecen fugas de memoria y degradaciones de rendimiento, lo que hace que el sistema sea inestable y requiera un reinicio manual.

### La respuesta: una capa de fiabilidad nativa

Frente a estos desafíos, las utilidades de terceros resultaron insuficientes. Por lo tanto, tomamos la decisión de **arquitecturar nuestra propia capa de resiliencia del sistema.**

`WindowsAutoConfig` actúa como un piloto automático que toma el control del sistema operativo para:

- **Garantizar la recuperación automática:** Después de un fallo, garantiza la apertura de la sesión y el reinicio de su aplicación principal.
- **Garantizar el mantenimiento preventivo:** Permite programar un reinicio diario controlado con la ejecución de scripts personalizados de antemano.
- **Proteger la aplicación** de interrupciones inoportunas de Windows (actualizaciones, modo de suspensión...).

`WindowsAutoConfig` es la herramienta indispensable para cualquiera que necesite que una estación de trabajo Windows permanezca **fiable, estable y operativa sin supervisión continua.**

---

## 💡 Casos de uso típicos

*   **Señalización digital:** Garantizar que un software de señalización funcione 24/7 en una pantalla pública.
*   **Servidores domésticos e IoT:** Controlar un servidor Plex, una pasarela de Home Assistant o un objeto conectado desde un PC con Windows.
*   **Estaciones de supervisión:** Mantener una aplicación de supervisión (cámaras, registros de red) siempre activa.
*   **Quioscos interactivos:** Asegurarse de que la aplicación del quiosco se reinicie automáticamente después de cada reinicio.
*   **Automatización ligera:** Ejecutar scripts o procesos de forma continua para tareas de minería de datos o pruebas.

---

## ✨ Características clave

*   **Asistente de configuración gráfico:** No es necesario editar archivos para la configuración básica.
*   **Soporte multilingüe completo:** Interfaz y registros disponibles en 11 idiomas, con detección automática del idioma del sistema.
*   **Gestión de energía:** Desactive la suspensión de la máquina, la suspensión de la pantalla y el inicio rápido de Windows para una estabilidad máxima.
*   **Inicio de sesión automático (Auto-Login):** Gestiona el inicio de sesión automático, incluso en sinergia con la herramienta **Sysinternals AutoLogon** para una gestión segura de la contraseña.
*   **Control de Windows Update:** Evite que las actualizaciones y los reinicios forzados interrumpan su aplicación.
*   **Administrador de procesos:** Inicia, supervisa y reinicia automáticamente su aplicación principal en cada sesión.
*   **Reinicio diario programado:** Programe un reinicio diario para mantener la frescura del sistema.
*   **Acción previa al reinicio:** Ejecute un script personalizado (copia de seguridad, limpieza...) antes del reinicio programado.
*   **Registro detallado:** Todas las acciones se registran en archivos de registro para un diagnóstico fácil.
*   **Notificaciones (opcional):** Envíe informes de estado a través de Gotify.

---

## 🎯 Público objetivo y buenas prácticas

Este proyecto está diseñado para convertir un PC en un autómata fiable, ideal para casos de uso en los que la máquina está dedicada a una sola aplicación (servidor para un dispositivo IoT, señalización digital, estación de supervisión, etc.). No se recomienda para un ordenador de oficina de uso general.

*   **Actualizaciones importantes de Windows:** Para actualizaciones importantes (p. ej., de Windows 10 a 11), el procedimiento más seguro es **desinstalar** WindowsAutoConfig antes de la actualización y luego **reinstalarlo** después.
*   **Entornos corporativos:** Si su ordenador está en un dominio gestionado por objetos de directiva de grupo (GPO), consulte a su departamento de TI para asegurarse de que las modificaciones realizadas por este script no entren en conflicto con las políticas de su organización.

---

## 🚀 Instalación y puesta en marcha

**Nota sobre el idioma:** Los scripts de inicio (`1_install.bat` y `2_uninstall.bat`) muestran sus instrucciones en **inglés**. Esto es normal. Estos archivos actúan como simples lanzadores. Tan pronto como el asistente gráfico o los scripts de PowerShell tomen el relevo, la interfaz se adaptará automáticamente al idioma de su sistema operativo.

Poner en marcha **WindowsAutoConfig** es un proceso sencillo y guiado.

1.  **Descargue** o clone el proyecto en el ordenador que se va a configurar.
2.  Ejecute `1_install.bat`. El script le guiará a través de dos pasos:
    *   **Paso 1: Configuración a través del Asistente Gráfico.**
        Ajuste las opciones según sus necesidades. Las más importantes suelen ser el identificador para el inicio de sesión automático y la aplicación que se va a iniciar. Haga clic en `Guardar` para guardar.
        
![Asistente de configuración](assets/screenshot-wizard.png)
*El asistente gráfico intuitivo para configurar WindowsAutoConfig*
    *   **Paso 2: Instalación de las Tareas del Sistema.**
        El script le pedirá una confirmación para continuar. Se abrirá una ventana de seguridad de Windows (UAC). **Debe aceptarla** para permitir que el script cree las tareas programadas necesarias.
3.  ¡Eso es todo! En el próximo reinicio, se aplicarán sus configuraciones.

---

## 🔧 Configuración
Puede ajustar la configuración en cualquier momento de dos maneras:

### 1. Asistente gráfico (método sencillo)
Vuelva a ejecutar `1_install.bat` para abrir de nuevo la interfaz de configuración. Modifique sus ajustes y guarde.

### 2. Archivo `config.ini` (método avanzado)
Abra `config.ini` con un editor de texto para un control granular.

#### Nota importante sobre el inicio de sesión automático y las contraseñas
Por razones de seguridad, **WindowsAutoConfig nunca gestiona ni almacena contraseñas en texto claro.** A continuación se explica cómo configurar el inicio de sesión automático de forma eficaz y segura:

*   **Escenario 1: La cuenta de usuario no tiene contraseña.**
    Simplemente introduzca el nombre de usuario en el asistente gráfico o en `AutoLoginUsername` en el archivo `config.ini`.

*   **Escenario 2: La cuenta de usuario tiene una contraseña (método recomendado).**
    1.  Descargue la herramienta oficial **[Sysinternals AutoLogon](https://download.sysinternals.com/files/AutoLogon.zip)** de Microsoft (enlace de descarga directa).
    2.  Inicie AutoLogon e introduzca el nombre de usuario, el dominio y la contraseña. Esta herramienta almacenará la contraseña de forma segura en el Registro.
    3.  En la configuración de **WindowsAutoConfig**, ahora puede dejar el campo `AutoLoginUsername` vacío (el script detectará el usuario configurado por AutoLogon leyendo la clave de Registro correspondiente) o rellenarlo para estar seguro. Nuestro script se asegurará de que la clave de Registro `AutoAdminLogon` esté correctamente activada para finalizar la configuración.

#### Configuración avanzada: `PreRebootActionCommand`
Esta potente función le permite ejecutar un script antes del reinicio diario. La ruta puede ser:
- **Absoluta:** `C:\Scripts\mi_copia_de_seguridad.bat`
- **Relativa al proyecto:** `PreReboot.bat` (el script buscará este archivo en la raíz del proyecto).
- **Usando `%USERPROFILE%`:** `%USERPROFILE%\Desktop\limpieza.ps1` (el script reemplazará inteligentemente `%USERPROFILE%` por la ruta del perfil del usuario de inicio de sesión automático).

---

## 📂 Estructura del proyecto
```
WindowsAutoConfig/
├── 1_install.bat                # Punto de entrada para la instalación y configuración
├── 2_uninstall.bat              # Punto de entrada para la desinstalación
├── config.ini                   # Archivo de configuración central
├── config_systeme.ps1           # Script principal para la configuración de la máquina (se ejecuta al inicio)
├── config_utilisateur.ps1       # Script principal para la gestión de procesos de usuario (se ejecuta al iniciar sesión)
├── LaunchApp.bat                # (Ejemplo) Lanzador portátil para su aplicación principal
├── PreReboot.bat                # Script de ejemplo para la acción previa al reinicio
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

## ⚙️ Funcionamiento detallado
El núcleo de **WindowsAutoConfig** se basa en el Programador de tareas de Windows:

1.  **Al iniciar Windows**
    *   La tarea `WindowsAutoConfig_SystemStartup` se ejecuta con privilegios de `SYSTEM`.
    *   El script `config_systeme.ps1` lee `config.ini` y aplica todas las configuraciones de la máquina. También gestiona la creación/actualización de las tareas de reinicio.

2.  **Al iniciar sesión de usuario**
    *   La tarea `WindowsAutoConfig_UserLogon` se ejecuta.
    *   El script `config_utilisateur.ps1` lee la sección `[Process]` de `config.ini` y se asegura de que su aplicación principal se inicie correctamente. Si ya se estaba ejecutando, primero se detiene y luego se reinicia de forma limpia.

3.  **Diariamente (si está configurado)**
    *   La tarea `WindowsAutoConfig_PreRebootAction` ejecuta su script de copia de seguridad/limpieza.
    *   Unos minutos más tarde, la tarea `WindowsAutoConfig_ScheduledReboot` reinicia el ordenador.

---

### 🛠️ Herramientas de diagnóstico y desarrollo

El proyecto incluye scripts útiles para ayudarle a configurar y mantener el proyecto.

*   **`management/tools/Find-WindowInfo.ps1`**: Si no conoce el título exacto de la ventana de una aplicación (para configurarlo en `Close-AppByTitle.ps1`, por ejemplo), ejecute este script. Listará todas las ventanas visibles y el nombre de su proceso, ayudándole a encontrar la información precisa.
*   **`Fix-Encoding.ps1`**: Si modifica los scripts, esta herramienta se asegura de que se guarden con la codificación correcta (UTF-8 con BOM) para una compatibilidad perfecta con PowerShell 5.1 y los caracteres internacionales.

---

## 📄 Registro (Logging)
Para facilitar la solución de problemas, todo se registra.
*   **Ubicación:** En la subcarpeta `Logs/`.
*   **Archivos:** `config_systeme_ps_log.txt` y `config_utilisateur_log.txt`.
*   **Rotación:** Los registros antiguos se archivan automáticamente para evitar que se vuelvan demasiado grandes.

---

## 🗑️ Desinstalación
Para eliminar el sistema:
1.  Ejecute `2_uninstall.bat`.
2.  **Acepte la solicitud de privilegios (UAC)**.
3.  El script eliminará limpiamente todas las tareas programadas y restaurará la configuración principal del sistema.

**Nota sobre la reversibilidad:** La desinstalación no solo elimina las tareas programadas. También restaura la configuración principal del sistema a su estado predeterminado para devolverle un sistema limpio:
*   Las actualizaciones de Windows se reactivan.
*   El inicio rápido se reactiva.
*   Se elimina la política de bloqueo de OneDrive.
*   El script le propondrá desactivar el inicio de sesión automático.

Su sistema vuelve a ser así una estación de trabajo estándar, sin modificaciones residuales.

---

## ❤️ Licencia y contribuciones
Este proyecto se distribuye bajo la licencia **GPLv3**. El texto completo está disponible en el archivo `LICENSE`.

Las contribuciones, ya sea en forma de informes de errores, sugerencias de mejora o "pull requests", son bienvenidas.
