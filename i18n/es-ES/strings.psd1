@{
    # ==============================================================================
    # ARCHIVO DE IDIOMA : ESPAÑOL (ES-ES)
    # ==============================================================================

    # ------------------------------------------------------------------------------
    # 1. INTERFAZ GRÁFICA (firstconfig.ps1)
    # ------------------------------------------------------------------------------

    # Títulos y navegación
    ConfigForm_Title = "Asistente de configuración - WindowsOrchestrator"
    ConfigForm_Tab_Basic = "Básico"
    ConfigForm_Tab_Advanced = "Avanzado"
    ConfigForm_SubTabMain = "Principal"
    ConfigForm_SubTabBackup = "Copia de seguridad"
    ConfigForm_SubTabOtherAccount = "Opciones y cuenta"

    # Grupo: Sesión de usuario
    ConfigForm_EnableSessionManagementCheckbox = "Activar el inicio de sesión automático (Autologon)"
    ConfigForm_SecureAutologonModeDescription = "(Abre el escritorio y bloquea la sesión inmediatamente)"
    ConfigForm_BackgroundTaskModeDescription = "(Inicia la aplicación de forma invisible, sin abrir sesión)"
    ConfigForm_SessionEulaNote = "(Al marcarlo, acepta la licencia de la herramienta Microsoft Autologon)"
    ConfigForm_UseAutologonAssistantCheckbox = "Usar el asistente para configurar la herramienta Autologon (si es necesario)"
    ConfigForm_AutoLoginUsernameLabel = "Identificador para Autologon (opcional):"

    # Grupo: Configuración de Windows
    ConfigForm_WindowsSettingsGroup = "Configuración de Windows"
    ConfigForm_DisableFastStartupCheckbox = "Desactivar el inicio rápido de Windows"
    ConfigForm_DisableSleepCheckbox = "Desactivar la suspensión automática"
    ConfigForm_DisableScreenSleepCheckbox = "Desactivar la suspensión de pantalla"
    ConfigForm_DisableWindowsUpdateCheckbox = "Bloquear el servicio Windows Update"
    ConfigForm_DisableAutoRebootCheckbox = "Desactivar el reinicio automático tras actualización"

    # Grupo: OneDrive
    ConfigForm_OneDriveModeLabel = "Gestión de OneDrive:"
    ConfigForm_OneDriveMode_Block = "Bloquear (directiva de sistema)"
    ConfigForm_OneDriveMode_Close = "Cerrar al inicio"
    ConfigForm_OneDriveMode_Ignore = "No hacer nada"

    # Grupo: Cierre y aplicación
    ConfigForm_Section_Closure = "Cierre programado de la aplicación"
    ConfigForm_EnableScheduledCloseCheckbox = "Activar el cierre programado"
    ConfigForm_CloseTimeLabel = "Hora de cierre (HH:MM):"
    ConfigForm_CloseCommandLabel = "Comando de cierre a ejecutar:"
    ConfigForm_CloseArgumentsLabel = "Argumentos para el comando:"

    ConfigForm_Section_Reboot = "Reinicio y ciclo diario"
    ConfigForm_EnableScheduledRebootCheckbox = "Activar el reinicio diario"
    ConfigForm_RebootTimeLabel = "Hora del reinicio programado (HH:MM):"

    ConfigForm_ProcessToLaunchLabel = "Aplicación a iniciar:"
    ConfigForm_ProcessArgumentsLabel = "Argumentos para la aplicación:"
    ConfigForm_ProcessToMonitorLabel = "Nombre del proceso a supervisar (sin .exe):"
    ConfigForm_StartProcessMinimizedCheckbox = "Iniciar la aplicación principal minimizada en la barra de tareas"
    ConfigForm_LaunchConsoleModeLabel = "Modo de inicio de consola:"
    ConfigForm_LaunchConsoleMode_Standard = "Inicio estándar (recomendado)"
    ConfigForm_LaunchConsoleMode_Legacy = "Inicio heredado (consola legacy)"

    # Grupo: Copia de seguridad
    ConfigForm_DatabaseBackupGroupTitle = "Copia de seguridad de bases de datos (opcional)"
    ConfigForm_EnableBackupCheckbox = "Activar la copia de seguridad antes del reinicio"
    ConfigForm_BackupSourceLabel = "Carpeta de origen de datos:"
    ConfigForm_BackupDestinationLabel = "Carpeta de destino de la copia de seguridad:"
    ConfigForm_BackupTimeLabel = "Hora de la copia de seguridad (HH:MM):"
    ConfigForm_BackupKeepDaysLabel = "Periodo de retención de copias (en días):"

    # Grupo: Opciones de instalación y cuenta de destino
    ConfigForm_InstallOptionsGroup = "Opciones de instalación"
    ConfigForm_SilentModeCheckbox = "Ocultar las ventanas de consola durante la instalación/desinstalación"
    ConfigForm_OtherAccountGroupTitle = "Personalizar para otro usuario"
    ConfigForm_OtherAccountDescription = "Permite especificar una cuenta de usuario alternativa para la ejecución de tareas programadas. Requiere privilegios de administrador para la configuración entre cuentas."
    ConfigForm_OtherAccountUsernameLabel = "Nombre de la cuenta de usuario a configurar:"

    # Botones y mensajes GUI
    ConfigForm_SaveButton = "Guardar y cerrar"
    ConfigForm_CancelButton = "Cancelar"
    ConfigForm_SaveSuccessMessage = "Configuración guardada en '{0}'"
    ConfigForm_SaveSuccess = "¡Configuración guardada con éxito!"
    ConfigForm_SaveSuccessCaption = "Éxito"
    ConfigForm_ConfigWizardCancelled = "Asistente de configuración cancelado."
    ConfigForm_PathError = "No se han podido determinar las rutas del proyecto. Error: '{0}'. El script se cerrará."
    ConfigForm_PathErrorCaption = "Error crítico de ruta"
    ConfigForm_ModelFileNotFoundError = "ERROR: No se encuentra el archivo modelo 'management\defaults\default_config.ini' Y no existe ningún 'config.ini'. Instalación imposible."
    ConfigForm_ModelFileNotFoundCaption = "Archivo modelo ausente"
    ConfigForm_CopyError = "No se ha podido crear el archivo 'config.ini' a partir del modelo. Error: '{0}'."
    ConfigForm_CopyErrorCaption = "Error de copia"
    ConfigForm_OverwritePrompt = "Ya existe un archivo de configuración 'config.ini'.\n\n¿Desea reemplazarlo por el modelo por defecto?\n\nATENCIÓN: Se perderán sus ajustes actuales."
    ConfigForm_OverwriteCaption = "¿Reemplazar la configuración existente?"
    ConfigForm_ResetSuccess = "El archivo 'config.ini' se ha restablecido con los valores por defecto."
    ConfigForm_ResetSuccessCaption = "Restablecimiento realizado"
    ConfigForm_OverwriteError = "No se ha podido reemplazar 'config.ini' por el modelo. Error: '{0}'."
    ConfigForm_InvalidTimeFormat = "El formato de hora debe ser HH:MM (ej: 03:55)."
    ConfigForm_InvalidTimeFormatCaption = "Formato inválido"
    ConfigForm_InvalidTimeLogic = "La hora de cierre debe ser ANTERIOR a la hora del reinicio programado."
    ConfigForm_InvalidTimeLogicCaption = "Lógica temporal inválida"
    ConfigForm_AllSysOptimizedNote = "✔ Estos parámetros están optimizados para {0}. Se recomienda no modificarlos."

    # ------------------------------------------------------------------------------
    # 2. SCRIPT DE SISTEMA (config_systeme.ps1)
    # ------------------------------------------------------------------------------

    # Logs generales
    Log_StartingScript = "Iniciando '{0}' ('{1}')..."
    Log_CheckingNetwork = "Verificando la conectividad de red..."
    Log_NetworkDetected = "Conectividad de red detectada."
    Log_NetworkRetry = "Red no disponible, reintentando en 10s..."
    Log_NetworkFailed = "Red no establecida. Gotify podría fallar."
    Log_ExecutingSystemActions = "Ejecutando las acciones de sistema configuradas..."
    Log_SettingNotSpecified = "El parámetro '{0}' no está especificado."
    Log_ScriptFinished = "'{0}' ('{1}') finalizado."
    Log_ErrorsOccurred = "Se produjeron errores durante la ejecución."
    Log_CapturedError = "ERROR CAPTURADO: '{0}'"
    Error_FatalScriptError = "ERROR FATAL DEL SCRIPT (bloque principal): '{0}' \n'{1}'"
    System_ConfigCriticalError = "Fallo crítico: config.ini."

    # Gestión de usuario de destino
    Log_ReadRegistryForUser = "AutoLoginUsername no especificado. Intentando leer DefaultUserName desde el Registro."
    Log_RegistryUserFound = "Usando DefaultUserName del Registro como usuario de destino: '{0}'."
    Log_RegistryUserNotFound = "DefaultUserName del Registro no encontrado o vacío. No hay usuario de destino por defecto."
    Log_RegistryReadError = "Error al leer DefaultUserName desde el Registro: '{0}'"
    Log_ConfigUserFound = "Usando AutoLoginUsername de config.ini como usuario de destino: '{0}'."

    # --- Acciones: Configuración de Windows ---
    Log_DisablingFastStartup = "Cfg: Desactivando el inicio rápido."
    Action_FastStartupDisabled = "- El inicio rápido de Windows está desactivado."
    Log_FastStartupAlreadyDisabled = "El inicio rápido de Windows ya está desactivado."
    Action_FastStartupVerifiedDisabled = "- El inicio rápido de Windows está desactivado."

    Log_EnablingFastStartup = "Cfg: Activando el inicio rápido."
    Action_FastStartupEnabled = "- El inicio rápido de Windows está activado."
    Log_FastStartupAlreadyEnabled = "El inicio rápido de Windows ya está activado."
    Action_FastStartupVerifiedEnabled = "- El inicio rápido de Windows está activado."
    Error_DisableFastStartupFailed = "Error al desactivar el inicio rápido: '{0}'"
    Error_EnableFastStartupFailed = "Error al activar el inicio rápido: '{0}'"

    Log_DisablingSleep = "Desactivando la suspensión de la máquina..."
    Action_SleepDisabled = "- La suspensión automática está desactivada."
    Error_DisableSleepFailed = "Error al desactivar la suspensión automática: '{0}'"

    Log_DisablingScreenSleep = "Desactivando la suspensión de pantalla..."
    Action_ScreenSleepDisabled = "- La suspensión de pantalla está desactivada."
    Error_DisableScreenSleepFailed = "Error al desactivar la suspensión de pantalla: '{0}'"

    Log_DisablingUpdates = "Desactivando las actualizaciones de Windows..."
    Action_UpdatesDisabled = "- El servicio Windows Update está bloqueado."
    Log_EnablingUpdates = "Activando las actualizaciones de Windows..."
    Action_UpdatesEnabled = "- El servicio Windows Update está activo."
    Error_UpdateMgmtFailed = "Error al gestionar las actualizaciones de Windows: '{0}'"

    Log_DisablingAutoReboot = "Desactivando el reinicio forzado por Windows Update..."
    Action_AutoRebootDisabled = "- El reinicio automático tras actualización está desactivado."
    Error_DisableAutoRebootFailed = "Error al desactivar el reinicio automático tras actualización: '{0}'"

    # --- Acciones: Sesión y OneDrive ---
    Log_EnablingAutoLogin = "Verificando/Activando la apertura de sesión automática..."
    Action_AutoAdminLogonEnabled = "- Apertura de sesión automática activada."
    Action_AutoLogonAutomatic = "- Apertura de sesión automática activada para '{0}' (modo: Autologon)."
    Action_AutoLogonSecure = "- Apertura de sesión automática activada para '{0}' (modo: seguro)."
    Action_AutologonVerified = "- La apertura de sesión automática está activa."
    Action_DefaultUserNameSet = "Usuario por defecto establecido en: '{0}'."
    Log_AutoLoginUserUnknown = "Apertura de sesión automática activada pero no se pudo determinar el usuario de destino."
    Error_AutoLoginFailed = "Error al configurar la apertura de sesión automática: '{0}'"
    Error_AutoLoginUserUnknown = "Apertura de sesión automática activada pero no se pudo determinar el usuario de destino."
    Error_SecureAutoLoginFailed = "Error al configurar la conexión segura: '{0}'"
    Action_LockTaskConfigured = "Bloqueo de sesión única configurado para '{0}'."

    Log_DisablingAutoLogin = "Desactivando la apertura de sesión automática..."
    Action_AutoAdminLogonDisabled = "- La apertura de sesión automática está desactivada."
    Error_DisableAutoLoginFailed = "Error al desactivar la apertura de sesión automática: '{0}'"

    Log_DisablingOneDrive = "Desactivando OneDrive (directiva)..."
    Log_EnablingOneDrive = "Activando/Manteniendo OneDrive (directiva)..."
    Action_OneDriveDisabled = "- OneDrive está desactivado (directiva)."
    Action_OneDriveEnabled = "- OneDrive está permitido."
    Action_OneDriveClosed = "- Proceso de OneDrive finalizado."
    Action_OneDriveBlocked = "- OneDrive está bloqueado (directiva de sistema) y el proceso se ha detenido."
    Action_OneDriveAutostartRemoved = "- Inicio automático de OneDrive desactivado para el usuario '{0}'."
    Action_OneDriveIgnored = "- Directiva de bloqueo de OneDrive eliminada (modo ignorar)."
    Error_DisableOneDriveFailed = "Error al desactivar OneDrive: '{0}'"
    Error_EnableOneDriveFailed = "Error al activar OneDrive: '{0}'"
    Action_OneDriveClean = "- OneDrive está cerrado y su inicio automático desactivado."

    # --- Acciones: Planificación ---
    Log_ConfiguringReboot = "Configurando el reinicio programado a las {0}..."
    Action_RebootScheduled = "- Reinicio programado a las {0}."
    Error_RebootScheduleFailed = "Error al configurar la tarea de reinicio programado ({0}) '{1}': '{2}'."
    Log_RebootTaskRemoved = "Hora de reinicio no especificada. Eliminando la tarea '{0}'."

    Action_BackupTaskConfigured = "- Copia de seguridad de datos programada a las {0}."
    Error_BackupTaskFailed = "Error al configurar la tarea de copia de seguridad: '{0}'"
    System_BackupTaskDescription = "Orchestrator: Ejecuta la copia de seguridad de datos antes del reinicio."
    System_BackupScriptNotFound = "No se encuentra el script de copia de seguridad dedicado '{0}'."

    # --- Mensajes de sistema v1.73 (Inferencia) ---
    Log_System_BackupSynced = "- Hora de copia de seguridad sincronizada con el cierre ({0}). Modo Watchdog activado."
    Log_System_RebootTaskSkipped = "- Reinicio activado sin hora fija. Tarea programada eliminada (se gestionará por encadenamiento)."
    Error_System_BackupNoTime = "Copia de seguridad activada pero no hay hora definida ni hora de cierre de referencia. Tarea omitida."

    # Gestión de procesos de sistema (Tarea en segundo plano)
    Log_System_NoProcessSpecified = "No se ha especificado ninguna aplicación para iniciar. No se realiza ninguna acción."
    Log_System_ProcessToMonitor = "Supervisando el nombre del proceso: '{0}'."
    Log_System_ProcessAlreadyRunning = "El proceso '{0}' (PID: {1}) ya está en ejecución. No es necesaria ninguna acción."
    Action_System_ProcessAlreadyRunning = "El proceso '{0}' ya está en ejecución (PID: {1})."
    Log_System_NoMonitor = "No se ha especificado ningún proceso a supervisar. Omitiendo verificación."
    Log_System_ProcessStarting = "Iniciando proceso en segundo plano '{0}' mediante '{1}'..."
    Action_System_ProcessStarted = "- Proceso en segundo plano '{0}' iniciado (vía '{1}')."
    Error_System_ProcessManagementFailed = "Error al gestionar el proceso en segundo plano '{0}': '{1}'"
    Action_System_CloseTaskConfigured = "- Tarea de cierre del proceso en segundo plano configurada para '{0}' a las {1}."
    Error_System_CloseTaskFailed = "Error al crear la tarea de cierre del proceso en segundo plano: '{0}'"
    System_ProcessNotDefined = "La aplicación a iniciar no está definida para el modo BackgroundTask (contexto SYSTEM sin interfaz gráfica)."

    # ------------------------------------------------------------------------------
    # 3. SCRIPT DE USUARIO (config_utilisateur.ps1)
    # ------------------------------------------------------------------------------
    Log_User_StartingScript = "Iniciando '{0}' ('{1}') para el usuario '{2}'..."
    Log_User_ExecutingActions = "Ejecutando las acciones configuradas para el usuario '{0}'..."
    Log_User_CannotReadConfig = "No se ha podido leer o analizar '{0}'. Deteniendo las configuraciones de usuario."
    Log_User_ScriptFinished = "'{0}' ('{1}') para el usuario '{2}' finalizado."

    Log_User_ManagingProcess = "Gestionando el proceso de usuario (bruto:'{0}', resuelto:'{1}'). Método: '{2}'"
    Log_User_ProcessWithArgs = "Con los argumentos: '{0}'"
    Log_User_ProcessToMonitor = "Supervisando el nombre del proceso: '{0}'."
    Log_User_ProcessAlreadyRunning = "El proceso '{0}' (PID: {1}) ya está en ejecución para el usuario actual. No es necesaria ninguna acción."
    Action_User_ProcessAlreadyRunning = "El proceso '{0}' ya está en ejecución (PID: {1})."
    Log_User_NoMonitor = "No se ha especificado ningún proceso a supervisar. Se ignora la verificación."
    Log_User_NoProcessSpecified = "No se ha especificado ningún proceso o la ruta está vacía."
    Log_User_BaseNameError = "Error al extraer el nombre base de '{0}' (directo)."
    Log_User_EmptyBaseName = "El nombre base del proceso a supervisar está vacío."
    Log_User_WorkingDirFallback = "El nombre del proceso '{0}' no es una ruta de archivo; directorio de trabajo establecido en '{1}' para '{2}'."
    Log_User_WorkingDirNotFound = "No se encuentra el directorio de trabajo '{0}'. No se establecerá."

    Log_User_ProcessStopping = "El proceso '{0}' (PID: {1}) está en ejecución. Deteniendo..."
    Action_User_ProcessStopped = "Proceso '{0}' detenido."
    Log_User_ProcessRestarting = "Reiniciando vía '{0}': '{1}' con argumentos: '{2}'"
    Action_User_ProcessRestarted = "- Proceso '{0}' reiniciado (vía '{1}')."
    Log_User_ProcessStarting = "Proceso '{0}' no encontrado. Iniciando vía '{1}': '{2}' con argumentos: '{3}'"
    Action_User_ProcessStarted = "- Proceso '{0}' iniciado."

    Error_User_LaunchMethodUnknown = "Método de inicio '{0}' no reconocido. Opciones: direct, powershell, cmd."
    Error_User_InterpreterNotFound = "Intérprete '{0}' no encontrado para el método '{1}'."
    Error_User_ProcessManagementFailed = "Error al gestionar el proceso '{0}' (Método: '{1}', Ruta: '{2}', Args: '{3}'): '{4}'. StackTrace: '{5}'"
    Error_User_ExeNotFound = "Archivo ejecutable para el proceso '{0}' (modo directo) NO ENCONTRADO."
    Error_User_FatalScriptError = "ERROR FATAL DEL SCRIPT DE USUARIO '{0}': '{1}' \n'{2}'"
    Error_User_VarExpansionFailed = "Error durante la expansión de variables para el proceso '{0}': '{1}'"

    Action_User_CloseTaskConfigured = "- Cierre de la aplicación programado a las {1}."
    Error_User_CloseTaskFailed = "Error al crear la tarea de cierre de la aplicación '{0}': '{1}'"

    # ------------------------------------------------------------------------------
    # 4. MÓDULO DE COPIA DE SEGURIDAD (Invoke-DatabaseBackup.ps1)
    # ------------------------------------------------------------------------------
    Log_Backup_Starting = "Iniciando el proceso de copia de seguridad de bases de datos..."
    Log_Backup_Disabled = "La copia de seguridad de bases de datos está desactivada en config.ini. Omitiendo."
    Log_Backup_PurgeStarting = "Iniciando la limpieza de copias antiguas (manteniendo los últimos {0} días)..."
    Log_Backup_PurgingFile = "Purgando copia de seguridad antigua: '{0}'."
    Log_Backup_NoFilesToPurge = "No hay copias antiguas que limpiar."
    Log_Backup_RetentionPolicy = "Política de retención: {0} día(s)."
    Log_Backup_NoFilesFound = "No se han encontrado archivos modificados en las últimas 24 horas para respaldar."
    Log_Backup_FilesFound = "Se han encontrado {0} archivo(s) para respaldar (incluyendo archivos vinculados)."
    Log_Backup_CopyingFile = "Copia de seguridad de '{0}' en '{1}' realizada con éxito."
    Log_Backup_AlreadyRunning = "La copia de seguridad ya está en ejecución (antigüedad del bloqueo: {0} min). Omitiendo."

    Action_Backup_Completed = "Copia de seguridad de {0} archivo(s) completada con éxito."
    Action_Backup_DestinationCreated = "Carpeta de destino de la copia de seguridad '{0}' creada."
    Action_Backup_PurgeCompleted = "Limpieza de {0} copia(s) antigua(s) completada."

    Error_Backup_PathNotFound = "No se encuentra la ruta de origen o destino '{0}' para la copia. Operación cancelada."
    Error_Backup_DestinationCreationFailed = "Error al crear la carpeta de destino '{0}': '{1}'"
    Error_Backup_InsufficientPermissions = "Permisos insuficientes para escribir en la carpeta de copia de seguridad: '{0}'"
    Error_Backup_InsufficientSpace = "Espacio en disco insuficiente. Requerido: {0:N2} MB, Disponible: {1:N2} MB"
    Error_Backup_PurgeFailed = "Error al purgar la copia antigua '{0}': '{1}'"
    Error_Backup_CopyFailed = "Error al respaldar el archivo '{0}': '{1}'"
    Error_Backup_ProcessRunning = "ABANDONANDO COPIA: El proceso '{0}' está activo. Riesgo de corrupción de datos."
    Error_Backup_Critical = "ERROR CRÍTICO durante el proceso de copia de seguridad: '{0}'"
    Backup_ConfigLoadError = "No se ha podido leer config.ini"
    Backup_InitError = "Error crítico de inicialización: '{0}'"

    # --- Mensajes Watchdog v1.73 ---
    Log_Backup_WatcherStarted = "Supervisión Watchdog iniciada para el proceso '{0}'."
    Log_Backup_ProcessClosed = "Proceso '{0}' cerrado correctamente."
    Log_Backup_TimeoutKill = "Proceso '{0}' finalizado forzosamente tras tiempo de espera ({1}s)."
    Error_Backup_TimeoutNoKill = "El proceso '{0}' sigue en ejecución tras el tiempo de espera ({1}s). Copia de seguridad abortada."
    Log_Backup_ChainedReboot = "Reinicio encadenado iniciado tras completar la copia de seguridad."

    # ------------------------------------------------------------------------------
    # 5. INSTALACIÓN Y DESINSTALACIÓN (install.ps1 / uninstall.ps1)
    # ------------------------------------------------------------------------------

    # Comunes
    Install_ElevationWarning = "Fallo en la elevación de privilegios. Por favor, ejecute este script como administrador."
    Uninstall_ElevationWarning = "Fallo en la elevación de privilegios. Por favor, ejecute este script como administrador."
    Install_PressEnterToExit = "Presione Intro para salir."
    Uninstall_PressEnterToExit = "Presione Intro para salir."
    Install_PressEnterToClose = "Presione Intro para cerrar esta ventana."
    Uninstall_PressEnterToClose = "Presione Intro para cerrar esta ventana."
    Exit_AutoCloseMessage = "Esta ventana se cerrará en {0} segundos..."
    Install_RebootMessage = "Instalación completada. El sistema se se reiniciará en {0} segundos para aplicar la configuración."
    Uninstall_RebootMessage = "Desinstalación completada. El sistema se reiniciará en {0} segundos para limpiar el entorno."

    # Instalación - Inicialización
    Install_UnsupportedArchitectureError = "Arquitectura de procesador no compatible: '{0}'"
    Install_ConfigIniNotFoundWarning = "No se encuentra config.ini en el directorio principal supuesto ('{0}')."
    Install_ProjectRootPrompt = "Por favor, introduzca la ruta completa del directorio raíz de los scripts de WindowsOrchestrator (ej: C:\WindowsOrchestrator)"
    Install_InvalidProjectRootError = "Directorio raíz del proyecto inválido o config.ini no encontrado: '{0}'"
    Install_PathDeterminationError = "Error durante la determinación inicial de rutas: '{0}'"
    Install_MissingSystemFile = "Falta un archivo de sistema requerido: '{0}'"
    Install_MissingUserFile = "Falta un archivo de usuario requerido: '{0}'"
    Install_MissingFilesAborted = "Faltan los archivos principales del script en '{0}'. Instalación cancelada. Presione Intro para salir."
    Install_ProjectRootUsed = "Directorio raíz del proyecto utilizado: '{0}'"
    Install_UserTaskTarget = "La tarea de usuario se instalará para: '{0}'"
    Install_AutoLoginUserEmpty = "INFO: 'AutoLoginUsername' está vacío. Completando con el usuario instalador..."
    Install_AutoLoginUserUpdated = "ÉXITO: config.ini actualizado con 'AutoLoginUsername={0}'."
    Install_AutoLoginUserUpdateFailed = "ADVERTENCIA: Fallo al actualizar 'AutoLoginUsername' en config.ini: '{0}'"
    Install_LogPermissionsWarning = "ADVERTENCIA: No se han podido crear o establecer los permisos para la carpeta Logs. El registro de eventos podría fallar. Error: '{0}'"

    # Instalación - Asistente Autologon
    Install_AutologonAlreadyActive = "INFO: El inicio de sesión automático de Windows ya está activo. El asistente no es necesario."
    Install_DownloadingAutologon = "Descargando la herramienta Microsoft Autologon..."
    Install_AutologonDownloadFailed = "ERROR: Fallo al descargar Autologon.zip. Verifique su conexión a Internet."
    Install_ExtractingArchive = "Extrayendo archivo..."
    Install_AutologonFilesMissing = "Archivos requeridos ('{0}', Eula.txt) no encontrados tras la extracción."
    Install_AutologonExtractionFailed = "ADVERTENCIA: Fallo al preparar la herramienta Autologon. El archivo descargado podría estar corrupto."
    Install_AutologonDownloadFailedPrompt = "La descarga ha fallado. ¿Desea localizar el archivo Autologon.zip manualmente?\n\nPágina oficial: https://learn.microsoft.com/sysinternals/downloads/autologon"
    Install_AutologonUnsupportedArchitecture = "ERROR: Arquitectura de procesador no compatible ('{0}'). No se puede configurar Autologon."
    Install_EulaConsentMessage = "¿Acepta los términos de licencia de la herramienta Sysinternals Autologon?"
    Install_EulaConsentCaption = "Consentimiento de EULA requerido"
    Install_PromptReviewEula = "El Acuerdo de Licencia de Usuario Final (EULA) de Microsoft se abrirá en el Bloc de notas. Por favor, léalo y cierre la ventana para continuar."
    Install_EulaConsentRefused = "Consentimiento de licencia rechazado por el usuario. Configuración de Autologon cancelada."
    Install_EulaRejected = "Configuración de Autologon cancelada (EULA no aceptado)."
    Install_PromptUseAutologonTool = "La herramienta Autologon se abrirá ahora. Por favor, introduzca sus datos (usuario, dominio, contraseña) y haga clic en 'Enable'."
    Install_AutologonSelectZipTitle = "Seleccione el archivo Autologon.zip descargado"
    Install_AutologonFileSelectedSuccess = "ÉXITO: Se utilizará el archivo local '{0}'."
    Install_AutologonSuccess = "ÉXITO: Herramienta Autologon ejecutada. La apertura de sesión automática debería estar configurada."
    Install_ContinueNoAutologon = "La instalación continúa sin configurar Autologon."
    Install_AbortedByUser = "Instalación cancelada por el usuario."
    Install_AutologonDownloadFailedCaption = "Fallo del asistente Autologon"
    Install_ConfirmContinueWithoutAutologon = "El asistente Autologon ha fallado. ¿Desea continuar con la instalación sin el inicio de sesión automático?"
    Install_AutologonManualDownloadPrompt = @"
La descarga automática de la herramienta Autologon ha fallado.

Puede descargarla manualmente para activar esta función.

1.  Abra esta URL en su navegador: https://learn.microsoft.com/sysinternals/downloads/autologon
2.  Descargue y extraiga 'Autologon.zip'.
3.  Coloque todos los archivos extraídos (Autologon64.exe, etc.) en la siguiente carpeta:
    {0}
4.  Reinicie la instalación.

¿Desea continuar con la instalación ahora sin configurar Autologon?
"@

    # Instalación - Contraseña y tareas
    Install_PasswordRequiredPrompt = "El modo de sesión automática está activado. Se REQUIERE la contraseña de la cuenta '{0}' para configurar la tarea programada de forma segura."
    Install_PasswordSecurityInfo = "Esta contraseña se envía directamente a la API de Windows y NUNCA se almacena."
    Install_EnterPasswordPrompt = "Por favor, introduzca la contraseña para la cuenta '{0}'"
    Install_PasswordIncorrect = "Contraseña incorrecta o error de validación. Por favor, inténtelo de nuevo."
    Install_PasswordAttemptsRemaining = "Intentos restantes: {0}."
    Install_PasswordEmptyToCancel = "(Deje vacío e intro para cancelar)"
    Install_PasswordMaxAttemptsReached = "Número máximo de intentos alcanzado. Instalación cancelada."
    Install_StartConfiguringTasks = "Iniciando la configuración de tareas programadas..."
    Install_CreatingSystemTask = "Creando/Actualizando tarea de sistema '{0}'..."
    Install_SystemTaskDescription = "WindowsOrchestrator: Ejecuta el script de configuración de sistema al inicio."
    Install_SystemTaskConfiguredSuccess = "Tarea '{0}' configurada con éxito."
    Install_CreatingUserTask = "Creando/Actualizando tarea de usuario '{0}' para '{1}'..."
    Install_UserTaskDescription = "WindowsOrchestrator: Ejecuta el script de configuración de usuario al abrir sesión."
    Install_MainTasksConfigured = "Tareas programadas principales configuradas."
    Install_DailyRebootTasksNote = "Las tareas para el reinicio diario y la acción de cierre serán gestionadas por '{0}' durante su ejecución."
    Install_TaskCreationSuccess = "Tareas creadas con éxito utilizando las credenciales proporcionadas."

    # Instalación - Ejecución y fin
    Install_AttemptingInitialLaunch = "Intentando el lanzamiento inicial de los scripts de configuración..."
    Install_ExecutingSystemScript = "Ejecutando config_systeme.ps1 para aplicar las configuraciones de sistema iniciales..."
    Install_SystemScriptSuccess = "config_systeme.ps1 ejecutado con éxito (código de salida 0)."
    Install_SystemScriptWarning = "config_systeme.ps1 finalizado con código de salida: {0}. Verifique los logs en '{1}\Logs'."
    Install_SystemScriptError = "Error durante la ejecución inicial de config_systeme.ps1: '{0}'"
    Install_Trace = "Traza: '{0}'"
    Install_ExecutingUserScript = "Ejecutando config_utilisateur.ps1 para '{0}' para aplicar las configuraciones de usuario iniciales..."
    Install_UserConfigLaunched = "ÉXITO: Script de configuración de usuario lanzado."
    Install_UserScriptSuccess = "config_utilisateur.ps1 ejecutado con éxito para '{0}' (código de salida 0)."
    Install_UserScriptWarning = "config_utilisateur.ps1 para '{0}' finalizado con código de salida: '{1}'. Verifique los logs en '{2}\Logs'."
    Install_UserScriptError = "Error durante la ejecución inicial de config_utilisateur.ps1 para '{0}': '{1}'"
    Install_InstallationCompleteSuccess = "¡Instalación y lanzamiento inicial completados!"
    Install_InstallationCompleteWithErrors = "Instalación completada con errores durante el lanzamiento inicial del script. Verifique los mensajes anteriores."
    Install_CriticalErrorDuringInstallation = "Se ha producido un error crítico durante la instalación: '{0}'"
    Install_SilentMode_CompletedSuccessfully = "¡Instalación de WindowsOrchestrator completada con éxito!\n\nTodos los registros se han guardado en la carpeta Logs."
    Install_SilentMode_CompletedWithErrors = "La instalación de WindowsOrchestrator ha finalizado con errores.\n\nPor favor, consulte los archivos de registro en la carpeta Logs para más detalles."

    # Desinstalación
    Uninstall_StartMessage = "Iniciando la desinstalación completa de WindowsOrchestrator..."
    Uninstall_AutoLogonQuestion = "[PREGUNTA] WindowsOrchestrator puede haber activado la sesión automática (Autologon). ¿Desea desactivarla ahora? (s/n)"
    Uninstall_RestoringSettings = "Restaurando los principales ajustes de Windows..."
    Uninstall_WindowsUpdateReactivated = "- Actualizaciones de Windows y reinicio automático: Reactivados."
    Uninstall_WindowsUpdateError = "- ERROR durante la reactivación de Windows Update: '{0}'"
    Uninstall_FastStartupReactivated = "- Inicio rápido de Windows: Reactivado (valor por defecto)."
    Uninstall_FastStartupError = "- ERROR durante la reactivación del inicio rápido: '{0}'"
    Uninstall_OneDriveReactivated = "- OneDrive: Reactivado (directiva de bloqueo eliminada)."
    Uninstall_OneDriveError = "- ERROR durante la reactivación de OneDrive: '{0}'"
    Uninstall_DeletingScheduledTasks = "Eliminando tareas programadas..."
    Uninstall_ProcessingTask = "Procesando tarea '{0}'..."
    Uninstall_TaskFoundAttemptingDeletion = " Encontrada. Intentando eliminar..."
    Uninstall_TaskSuccessfullyRemoved = " Eliminada con éxito."
    Uninstall_TaskDeletionFailed = " FALLO EN LA ELIMINACIÓN."
    Uninstall_TaskDeletionError = " ERROR durante la eliminación."
    Uninstall_TaskErrorDetail = "   Detalle: '{0}'"
    Uninstall_TaskNotFound = " No encontrada."
    Uninstall_CompletionMessage = "Desinstalación completada."
    Uninstall_TasksNotRemovedWarning = "Algunas tareas NO pudieron eliminarse: '{0}'."
    Uninstall_CheckTaskScheduler = "Por favor, verifique el Programador de tareas."
    Uninstall_FilesNotDeletedNote = "Nota: Los scripts y archivos de configuración no se eliminan de su disco."
    Uninstall_LSACleanAttempt = "INFO: Intentando la limpieza completa de secretos LSA vía Autologon.exe..."
    Uninstall_AutoLogonDisabled = "- Sesión automática: Desactivada (vía herramienta Autologon)."
    Uninstall_AutoLogonDisableError = "- ERROR durante el intento de desactivar la sesión automática: '{0}'"
    Uninstall_AutoLogonLeftAsIs = "- Sesión automática: Mantenida sin cambios (elección del usuario)."
    Uninstall_AutologonToolNotFound_Interactive = "[ADVERTENCIA] Herramienta Autologon.exe no encontrada. No se puede realizar la desactivación automática. Si desea desactivar la sesión automática, hágalo manualmente."
    Uninstall_AutologonDisablePrompt = "Por favor, haga clic en 'Disable' en la ventana de Autologon que se abrirá para finalizar la limpieza."
    Uninstall_AutologonNotActive = "INFO: El inicio de sesión automático no está activo. No es necesaria ninguna limpieza."
    Uninstall_SilentMode_CompletedSuccessfully = "¡Desinstalación de WindowsOrchestrator completada con éxito!\n\nTodos los registros se han guardado en la carpeta Logs."
    Uninstall_SilentMode_CompletedWithErrors = "La desinstalación de WindowsOrchestrator ha finalizado con errores.\n\nPor favor, consulte los archivos de registro en la carpeta Logs para más detalles."

    # ------------------------------------------------------------------------------
    # 6. NOTIFICACIONES (Gotify) Y COMUNES
    # ------------------------------------------------------------------------------
    Gotify_MessageDate = "Ejecutado el {0}."
    Gotify_SystemActionsHeader = "Acciones de sistema:"
    Gotify_NoSystemActions = "Sin acciones de sistema."
    Gotify_SystemErrorsHeader = "Errores de sistema:"
    Gotify_UserActionsHeader = "Acciones de usuario:"
    Gotify_NoUserActions = "Sin acciones de usuario."
    Gotify_UserErrorsHeader = "Errores de usuario:"
    Error_LanguageFileLoad = "Se ha producido un error crítico al cargar los archivos de idioma: '{0}'"
    Error_InvalidConfigValue = "Valor de configuración inválido para [{0}]{1}: '{2}'. Se esperaba el tipo '{3}'. Se utilizará el valor por defecto/vacío."
    Install_SplashMessage = "Operación en curso, por favor espere..."

    # --- v1.73 Modo puente ---
    Log_System_RebootBridgeScheduled = 'Reinicio activado (puente tras cierre + {0} min: {1}).'
}
