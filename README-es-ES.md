# WindowsAutoConfig ⚙️

[🇫🇷 Français](README-fr-FR.md) | [🇺🇸 English](README.md) | [🇩🇪 Deutsch](README-de-DE.md) | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md)

**Su piloto automático para estaciones de trabajo Windows dedicadas. Configure una vez y deje que el sistema se autogestione con total fiabilidad.**

![Licencia](https://img.shields.io/badge/Licence-GPLv3-blue.svg)
![Versión PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-blue)
![Estado](https://img.shields.io/badge/Statut-Opérationnel-brightgreen.svg)
![SO](https://img.shields.io/badge/OS-Windows_10_|_11-informational)
![Contribuciones](https://img.shields.io/badge/Contributions-Bienvenidas-brightgreen.svg)

---

## 🎯 El Manifiesto de WindowsAutoConfig

### El Problema
Implementar y mantener un equipo con Windows para una tarea única (kiosco interactivo, señalización digital, puesto de mando) es un desafío constante. Las actualizaciones inoportunas, las suspensiones inesperadas, la necesidad de reiniciar manualmente una aplicación después de un reinicio... Cada detalle puede convertirse en una fuente de fallos y requiere una intervención manual costosa en tiempo. Configurar cada puesto es un proceso repetitivo, largo y propenso a errores.

### La Solución: WindowsAutoConfig
**WindowsAutoConfig** transforma cualquier PC con Windows en un autómata fiable y predecible. Es un conjunto de scripts que se instalan localmente y que toman el control de la configuración del sistema para garantizar que su máquina haga exactamente lo que espera de ella, 24 horas al día, 7 días a la semana.

Actúa como un supervisor permanente, aplicando sus reglas en cada inicio y en cada inicio de sesión, para que usted no tenga que hacerlo más.

## ✨ Características Clave
*   **Asistente de Configuración Gráfico:** No es necesario editar archivos para los ajustes básicos.
*   **Gestión de Energía:** Desactive la suspensión de la máquina, de la pantalla y el inicio rápido de Windows para una estabilidad máxima.
*   **Inicio de Sesión Automático (Auto-Login):** Gestiona el inicio de sesión automático, incluyendo la sinergia con la herramienta **Sysinternals AutoLogon** para una gestión segura de la contraseña.
*   **Control de Windows Update:** Evite que las actualizaciones y los reinicios forzados interrumpan su aplicación.
*   **Administrador de Procesos:** Lanza, supervisa y reinicia automáticamente su aplicación principal en cada sesión.
*   **Reinicio Diario Programado:** Programe un reinicio diario para mantener la frescura del sistema.
*   **Acción Pre-Reinicio:** Ejecute un script personalizado (copia de seguridad, limpieza...) antes del reinicio programado.
*   **Registro Detallado:** Todas las acciones se registran en archivos de registro para un diagnóstico fácil.
*   **Notificaciones (Opcional):** Envíe informes de estado a través de Gotify.

---

## 🚀 Instalación y Primeros Pasos
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
    3.  En la configuración de **WindowsAutoConfig**, ahora puede dejar el campo `AutoLoginUsername` vacío (el script detectará el usuario configurado por AutoLogon) o rellenarlo para asegurarse. Nuestro script se asegurará de que la clave de Registro `AutoAdminLogon` esté bien activada para finalizar la configuración.

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
├── PreReboot.bat                # Ejemplo de script para la acción pre-reinicio
├── Logs/                        # (Creado automáticamente) Contiene los archivos de registro
└── management/
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

### 🛠️ Herramientas de Diagnóstico

El proyecto incluye scripts útiles para ayudarle a configurar aplicaciones complejas.

*   **`management/tools/Find-WindowInfo.ps1`**: Si necesita configurar la acción de pre-reinicio para una nueva aplicación y no conoce el título exacto de su ventana, esta herramienta es para usted. Lance su aplicación, luego ejecute este script en una consola de PowerShell. Listará todas las ventanas visibles y el nombre de su proceso, permitiéndole encontrar el título exacto a usar en el script `Close-AppByTitle.ps1`.

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
3.  El script eliminará limpiamente todas las tareas programadas creadas por el proyecto.

**Nota:** La desinstalación no anula los cambios del sistema (por ejemplo, la suspensión permanecerá desactivada) y no elimina la carpeta del proyecto.

---

## ❤️ Licencia y Contribuciones
Este proyecto se distribuye bajo la licencia **GPLv3**. El texto completo está disponible en el archivo `LICENSE`.

Las contribuciones, ya sea en forma de informes de errores, sugerencias de mejora o "pull requests", son bienvenidas.