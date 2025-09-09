# El Orquestador de Windows

<p align="center">
  <img src="https://img.shields.io/badge/Licencia-GPLv3-blue.svg" alt="Licencia">
  <img src="https://img.shields.io/badge/PowerShell-5.1%2B-blue" alt="Versión de PowerShell">
  <img src="https://img.shields.io/badge/Soporte-11_Idiomas-orange.svg" alt="Soporte multilingüe">
  <img src="https://img.shields.io/badge/SO-Windows_10_|_11-informational" alt="SO Soportados">
</p>

[🇺🇸 English](README.md) | [🇫🇷 Français](README-fr-FR.md) | [🇩🇪 Deutsch](README-de-DE.md) | **🇪🇸 Español** | [🇮🇳 हिंदी](README-hi-IN.md) | [🇯🇵 日本語](README-ja-JP.md) | [🇷🇺 Русский](README-ru-RU.md) | [🇨🇳 中文](README-zh-CN.md) | [🇸🇦 العربية](README-ar-SA.md) | [🇧🇩 বাংলা](README-bn-BD.md) | [🇮🇩 Bahasa Indonesia](README-id-ID.md)

---

Este proyecto automatiza una estación de trabajo Windows para que una aplicación pueda funcionar en ella sin supervisión.

<p align="center">
  <a href="https://wo.davalan.fr/"><strong>🔗 ¡Visite la página de inicio oficial para una presentación completa!</strong></a>
</p>

Después de un reinicio inesperado (debido a un corte de energía o un incidente), este proyecto se encarga de abrir la sesión de Windows y reiniciar automáticamente su aplicación, asegurando así la continuidad de su servicio. También permite planificar reinicios diarios para mantener la estabilidad del sistema.

Todas las acciones son controladas por un único archivo de configuración, creado durante la instalación.

### **Instalación**

1.  **Requisito previo (para el inicio de sesión automático):** Si desea que la sesión de Windows se abra sola, utilice previamente la herramienta **[Sysinternals AutoLogon](https://learn.microsoft.com/es-es/sysinternals/downloads/autologon)** para guardar la contraseña. Esta es la única configuración externa necesaria.
2.  **Lanzamiento:** Ejecute **`1_install.bat`**. Un asistente gráfico le guiará para crear su archivo de configuración. La instalación continuará y solicitará permiso de administrador (UAC).

### **Uso**

Una vez instalado, el proyecto es autónomo. Para modificar la configuración (cambiar la aplicación a lanzar, la hora de reinicio...), simplemente edite el archivo `config.ini` ubicado en el directorio del proyecto.

### **Desinstalación**

Ejecute **`2_uninstall.bat`**. El script eliminará toda la automatización y restaurará los principales parámetros de Windows a sus valores predeterminados.

*   **Nota importante:** Los únicos parámetros no restaurados son los relacionados con la gestión de energía (`powercfg`).
*   El directorio del proyecto con todos sus archivos permanece en su disco y puede ser eliminado manualmente.

### **Documentación Técnica**

Para una descripción detallada de la arquitectura, de cada script y de todas las opciones de configuración, por favor consulte la documentación de referencia.

➡️ **[Consultar la Documentación Técnica Detallada](./docs/es-ES/GUIA_DEL_DESARROLLADOR.md)**

---
**Licencia**: Este proyecto se distribuye bajo la licencia GPLv3. Ver el archivo `LICENSE`.
