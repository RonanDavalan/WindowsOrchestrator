@{
    # ==============================================================================
    # ARCHIVO DE IDIOMA: ESPAÑOL (es-ES)
    # ==============================================================================

    # ------------------------------------------------------------------------------
    # 1. INTERFAZ GRÁFICA (firstconfig.ps1)
    # ------------------------------------------------------------------------------

    # Títulos y Navegación
    ConfigForm_Title = "Asistente de Configuración - WindowsOrchestrator"
    ConfigForm_Tab_Basic = "Básico"
    ConfigForm_Tab_Advanced = "Avanzado"
    ConfigForm_SubTabMain = "Principal"
    ConfigForm_SubTabBackup = "Copia de Seguridad"
    ConfigForm_SubTabOtherAccount = "Opciones y Cuenta"

    # Grupo: Sesión de Usuario
    ConfigForm_EnableSessionManagementCheckbox = "Activar el inicio de sesión automático (Autologon)"
    ConfigForm_SecureAutologonModeDescription = "(Abre el escritorio y luego bloquea la sesión inmediatamente)"
    ConfigForm_BackgroundTaskModeDescription = "(Inicia la aplicación de forma invisible, sin abrir una sesión)"
    ConfigForm_SessionEulaNote = "(Al marcar, aceptas la licencia de la herramienta Microsoft Autologon)"
    ConfigForm_UseAutologonAssistantCheckbox = "Usar el asistente para configurar la herramienta Autologon (si es necesario)"
    ConfigForm_AutoLoginUsernameLabel = "Usuario para Autologon (opcional):"

    # Grupo: Configuración de Windows
    ConfigForm_WindowsSettingsGroup = "Configuración de Windows"
    ConfigForm_DisableFastStartupCheckbox = "Desactivar el inicio rápido de Windows"
    ConfigForm_DisableSleepCheckbox = "Desactivar la suspensión automática"
    ConfigForm_DisableScreenSleepCheckbox = "Desactivar la suspensión de la pantalla"
    ConfigForm_DisableWindowsUpdateCheckbox = "Bloquear el servicio de Windows Update"
    ConfigForm_DisableAutoRebootCheckbox = "Desactivar el reinicio automático después de una actualización"

    # Grupo: OneDrive
    ConfigForm_OneDriveModeLabel = "Gestión de OneDrive:"
    ConfigForm_OneDriveMode_Block = "Bloquear (política de sistema)"
    ConfigForm_OneDriveMode_Close = "Cerrar al inicio"
    ConfigForm_OneDriveMode_Ignore = "No hacer nada"

    # Grupo: Cierre y Aplicación
    ConfigForm_CloseAppGroupTitle = "Cierre Programado de la Aplicación"
    ConfigForm_CloseTimeLabel = "Hora de Cierre (HH:MM):"
    ConfigForm_CloseCommandLabel = "Comando de cierre a ejecutar:"
    ConfigForm_CloseArgumentsLabel = "Argumentos para el comando:"

    ConfigForm_MainAppGroupTitle = "Aplicación Principal y Ciclo Diario"
    ConfigForm_RebootTimeLabel = "Hora del Reinicio Programado (HH:MM):"
    ConfigForm_ProcessToLaunchLabel = "Aplicación a Iniciar:"
    ConfigForm_ProcessArgumentsLabel = "Argumentos para la aplicación:"
    ConfigForm_ProcessToMonitorLabel = "Nombre del Proceso a Monitorear (sin .exe):"
    ConfigForm_StartProcessMinimizedCheckbox = "Iniciar la aplicación principal minimizada en la barra de tareas"
    ConfigForm_LaunchConsoleModeLabel = "Modo de Lanzamiento de Consola:"
    ConfigForm_LaunchConsoleMode_Standard = "Lanzamiento Estándar (recomendado)"
    ConfigForm_LaunchConsoleMode_Legacy = "Lanzamiento Legacy (consola antigua)"

    # Grupo: Copia de Seguridad
    ConfigForm_DatabaseBackupGroupTitle = "Copia de Seguridad de Bases de Datos (Opcional)"
    ConfigForm_EnableBackupCheckbox = "Activar la copia de seguridad antes de reiniciar"
    ConfigForm_BackupSourceLabel = "Carpeta de origen de los datos:"
    ConfigForm_BackupDestinationLabel = "Carpeta de destino de la copia de seguridad:"
    ConfigForm_BackupTimeLabel = "Hora de la copia de seguridad (HH:MM):"
    ConfigForm_BackupKeepDaysLabel = "Duración de conservación de las copias de seguridad (en días):"

    # Grupo: Opciones de Instalación y Cuenta de Destino
    ConfigForm_InstallOptionsGroup = "Opciones de Instalación"
    ConfigForm_SilentModeCheckbox = "Ocultar las ventanas de la consola durante la instalación/desinstalación"
    ConfigForm_OtherAccountGroupTitle = "Personalizar para Otro Usuario"
    ConfigForm_OtherAccountDescription = "Permite especificar una cuenta de usuario alternativa para la ejecución de tareas programadas. Requiere privilegios de administrador para la configuración entre cuentas."
    ConfigForm_OtherAccountUsernameLabel = "Nombre de la cuenta de usuario a configurar:"

    # Botones y Mensajes de la GUI
    ConfigForm_SaveButton = "Guardar y Cerrar"
    ConfigForm_CancelButton = "Cancelar"
    ConfigForm_SaveSuccessMessage = "Configuración guardada en '{0}'"
    ConfigForm_SaveSuccess = "¡Configuración guardada con éxito!"
    ConfigForm_SaveSuccessCaption = "Éxito"
    ConfigForm_ConfigWizardCancelled = "Asistente de configuración cancelado."
    ConfigForm_PathError = "No se pudieron determinar las rutas del proyecto. Error: '{0}'. El script se cerrará."
    ConfigForm_PathErrorCaption = "Error Crítico de Ruta"
    ConfigForm_ModelFileNotFoundError = "ERROR: El archivo de plantilla 'management\defaults\default_config.ini' no se encuentra Y no existe 'config.ini'. La instalación es imposible."
    ConfigForm_ModelFileNotFoundCaption = "Archivo de Plantilla Faltante"
    ConfigForm_CopyError = "No se pudo crear el archivo 'config.ini' a partir de la plantilla. Error: '{0}'."
    ConfigForm_CopyErrorCaption = "Error de copia"
    ConfigForm_OverwritePrompt = "Ya existe un archivo de configuración 'config.ini'.\n\n¿Desea reemplazarlo con la plantilla predeterminada?\n\nADVERTENCIA: Se perderán sus ajustes actuales."
    ConfigForm_OverwriteCaption = "¿Reemplazar la configuración existente?"
    ConfigForm_ResetSuccess = "El archivo 'config.ini' ha sido restablecido a los valores predeterminados."
    ConfigForm_ResetSuccessCaption = "Restablecimiento Realizado"
    ConfigForm_OverwriteError = "No se pudo reemplazar 'config.ini' con la plantilla. Error: '{0}'."
    ConfigForm_InvalidTimeFormat = "El formato de hora debe ser HH:MM (ej: 03:55)."
    ConfigForm_InvalidTimeFormatCaption = "Formato Inválido"
    ConfigForm_InvalidTimeLogic = "La hora de cierre debe ser ANTERIOR a la hora del reinicio programado."
    ConfigForm_InvalidTimeLogicCaption = "Lógica Temporal Inválida"
    ConfigForm_AllSysOptimizedNote = "✔ Estos parámetros están optimizados para asegurar la estabilidad del sistema y el buen funcionamiento de su aplicación. Se recomienda no modificarlos."

    # ------------------------------------------------------------------------------
    # 2. SCRIPT DEL SISTEMA (config_systeme.ps1)
    # ------------------------------------------------------------------------------

    # Registros Generales
    Log_StartingScript = "Iniciando '{0}' ('{1}')..."
    Log_CheckingNetwork = "Verificando la conectividad de red..."
    Log_NetworkDetected = "Conectividad de red detectada."
    Log_NetworkRetry = "Red no disponible, nuevo intento en 10s..."
    Log_NetworkFailed = "Red no establecida. Gotify podría fallar."
    Log_ExecutingSystemActions = "Ejecutando las acciones de SISTEMA configuradas..."
    Log_SettingNotSpecified = "El parámetro '{0}' no está especificado."
    Log_ScriptFinished = "'{0}' ('{1}') finalizado."
    Log_ErrorsOccurred = "Se produjeron errores durante la ejecución."
    Log_CapturedError = "ERROR CAPTURADO: '{0}'"
    Error_FatalScriptError = "ERROR FATAL DEL SCRIPT (bloque principal): '{0}' \n'{1}'"
    System_ConfigCriticalError = "Fallo crítico: config.ini."

    # Gestión de Usuario de Destino
    Log_ReadRegistryForUser = "AutoLoginUsername no especificado. Intentando leer DefaultUserName desde el Registro."
    Log_RegistryUserFound = "Usando DefaultUserName del Registro como usuario de destino: '{0}'."
    Log_RegistryUserNotFound = "DefaultUserName del Registro no encontrado o vacío. No hay usuario de destino predeterminado."
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
    Error_DisableFastStartupFailed = "Fallo al desactivar el inicio rápido: '{0}'"
    Error_EnableFastStartupFailed = "Fallo al activar el inicio rápido: '{0}'"

    Log_DisablingSleep = "Desactivando la suspensión de la máquina..."
    Action_SleepDisabled = "- La suspensión automática está desactivada."
    Error_DisableSleepFailed = "Fallo al desactivar la suspensión automática: '{0}'"

    Log_DisablingScreenSleep = "Desactivando la suspensión de la pantalla..."
    Action_ScreenSleepDisabled = "- La suspensión de la pantalla está desactivada."
    Error_DisableScreenSleepFailed = "Fallo al desactivar la suspensión de la pantalla: '{0}'"

    Log_DisablingUpdates = "Desactivando las actualizaciones de Windows..."
    Action_UpdatesDisabled = "- El servicio de Windows Update está bloqueado."
    Log_EnablingUpdates = "Activando las actualizaciones de Windows..."
    Action_UpdatesEnabled = "- El servicio de Windows Update está activo."
    Error_UpdateMgmtFailed = "Fallo en la gestión de las actualizaciones de Windows: '{0}'"

    Log_DisablingAutoReboot = "Desactivando el reinicio forzado por Windows Update..."
    Action_AutoRebootDisabled = "- El reinicio automático después de una actualización está desactivado."
    Error_DisableAutoRebootFailed = "Fallo al desactivar el reinicio automático después de una actualización: '{0}'"

    # --- Acciones: Sesión y OneDrive ---
    Log_EnablingAutoLogin = "Verificando/Activando el inicio de sesión automático..."
    Action_AutoAdminLogonEnabled = "- Inicio de sesión automático activado."
    Action_AutoLogonAutomatic = "- Inicio de sesión automático activado para '{0}' (Modo: Autologon)."
    Action_AutoLogonSecure = "- Inicio de sesión automático activado para '{0}' (Modo: Seguro)."
    Action_AutologonVerified = "- El inicio de sesión automático está activo."
    Action_DefaultUserNameSet = "Usuario predeterminado establecido en: '{0}'."
    Log_AutoLoginUserUnknown = "Inicio de sesión automático activado pero no se pudo determinar el usuario de destino."
    Error_AutoLoginFailed = "Fallo en la configuración del inicio de sesión automático: '{0}'"
    Error_AutoLoginUserUnknown = "Inicio de sesión automático activado pero no se pudo determinar el usuario de destino."
    Error_SecureAutoLoginFailed = "Fallo en la configuración de la conexión segura: '{0}'"
    Action_LockTaskConfigured = "Bloqueo de sesión único configurado para '{0}'."

    Log_DisablingAutoLogin = "Desactivando el inicio de sesión automático..."
    Action_AutoAdminLogonDisabled = "- El inicio de sesión automático está desactivado."
    Error_DisableAutoLoginFailed = "Fallo al desactivar el inicio de sesión automático: '{0}'"

    Log_DisablingOneDrive = "Desactivando OneDrive (política)..."
    Log_EnablingOneDrive = "Activando/Manteniendo OneDrive (política)..."
    Action_OneDriveDisabled = "- OneDrive está desactivado (política)."
    Action_OneDriveEnabled = "- OneDrive está permitido."
    Action_OneDriveClosed = "- Proceso de OneDrive finalizado."
    Action_OneDriveBlocked = "- OneDrive está bloqueado (política de sistema) y el proceso ha sido detenido."
    Action_OneDriveAutostartRemoved = "- Inicio automático de OneDrive desactivado para el usuario '{0}'."
    Action_OneDriveIgnored = "- Política de bloqueo de OneDrive eliminada (modo Ignorar)."
    Error_DisableOneDriveFailed = "Fallo al desactivar OneDrive: '{0}'"
    Error_EnableOneDriveFailed = "Fallo al activar OneDrive: '{0}'"
    Action_OneDriveClean = "- OneDrive está cerrado y su inicio está desactivado."

    # --- Acciones: Planificación (Futuro) ---
    Log_ConfiguringReboot = "Configurando el reinicio programado a las {0}..."
    Action_RebootScheduled = "- Reinicio programado a las {0}."
    Error_RebootScheduleFailed = "Fallo en la configuración de la tarea de reinicio programado ({0}) '{1}': '{2}'."
    Log_RebootTaskRemoved = "Hora de reinicio no especificada. Eliminando la tarea '{0}'."

    Action_BackupTaskConfigured = "- Copia de seguridad de datos programada a las {0}."
    Error_BackupTaskFailed = "Fallo en la configuración de la tarea de copia de seguridad: '{0}'"
    System_BackupTaskDescription = "Orchestrator: Ejecuta la copia de seguridad de los datos antes del reinicio."
    System_BackupScriptNotFound = "El script de copia de seguridad dedicado '{0}' no se encuentra."

    # Gestión de Procesos del Sistema (Tarea de Fondo)
    Log_System_NoProcessSpecified = "No se ha especificado ninguna aplicación para iniciar. No se realiza ninguna acción."
    Log_System_ProcessToMonitor = "Monitoreando el nombre del proceso: '{0}'."
    Log_System_ProcessAlreadyRunning = "El proceso '{0}' (PID: {1}) ya se está ejecutando. No se necesita ninguna acción."
    Action_System_ProcessAlreadyRunning = "El proceso '{0}' ya se está ejecutando (PID: {1})."
    Log_System_NoMonitor = "No se ha especificado ningún proceso para monitorear. Omitiendo la verificación."
    Log_System_ProcessStarting = "Iniciando el proceso en segundo plano '{0}' a través de '{1}'..."
    Action_System_ProcessStarted = "- Proceso en segundo plano '{0}' iniciado (a través de '{1}')."
    Error_System_ProcessManagementFailed = "Fallo en la gestión del proceso en segundo plano '{0}': '{1}'"
    Action_System_CloseTaskConfigured = "- Tarea de detención del proceso en segundo plano configurada para '{0}' a las {1}."
    Error_System_CloseTaskFailed = "Fallo al crear la tarea de detención del proceso en segundo plano: '{0}'"
    System_ProcessNotDefined = "La aplicación a iniciar no está definida para el modo BackgroundTask (contexto SYSTEM sin interfaz gráfica)."

    # ------------------------------------------------------------------------------
    # 3. SCRIPT DEL USUARIO (config_utilisateur.ps1)
    # ------------------------------------------------------------------------------
    Log_User_StartingScript = "Iniciando '{0}' ('{1}') para el usuario '{2}'..."
    Log_User_ExecutingActions = "Ejecutando las acciones configuradas para el usuario '{0}'..."
    Log_User_CannotReadConfig = "No se puede leer o analizar '{0}'. Deteniendo las configuraciones de usuario."
    Log_User_ScriptFinished = "'{0}' ('{1}') para el usuario '{2}' finalizado."

    Log_User_ManagingProcess = "Gestionando el proceso de usuario (bruto:'{0}', resuelto:'{1}'). Método: '{2}'"
    Log_User_ProcessWithArgs = "Con los argumentos: '{0}'"
    Log_User_ProcessToMonitor = "Monitoreando el nombre del proceso: '{0}'."
    Log_User_ProcessAlreadyRunning = "El proceso '{0}' (PID: {1}) ya se está ejecutando para el usuario actual. No se necesita ninguna acción."
    Action_User_ProcessAlreadyRunning = "El proceso '{0}' ya se está ejecutando (PID: {1})."
    Log_User_NoMonitor = "No se ha especificado ningún proceso para monitorear. Se omite la verificación."
    Log_User_NoProcessSpecified = "No se ha especificado ningún proceso o la ruta está vacía."
    Log_User_BaseNameError = "Error al extraer el nombre base de '{0}' (directo)."
    Log_User_EmptyBaseName = "El nombre base del proceso a monitorear está vacío."
    Log_User_WorkingDirFallback = "El nombre del proceso '{0}' no es una ruta de archivo; Carpeta de trabajo establecida en '{1}' para '{2}'."
    Log_User_WorkingDirNotFound = "El directorio de trabajo '{0}' no se encuentra. No se establecerá."

    Log_User_ProcessStopping = "El proceso '{0}' (PID: {1}) se está ejecutando. Deteniendo..."
    Action_User_ProcessStopped = "Proceso '{0}' detenido."
    Log_User_ProcessRestarting = "Reiniciando a través de '{0}': '{1}' con los argumentos: '{2}'"
    Action_User_ProcessRestarted = "- Proceso '{0}' reiniciado (a través de '{1}')."
    Log_User_ProcessStarting = "Proceso '{0}' no encontrado. Iniciando a través de '{1}': '{2}' con los argumentos: '{3}'"
    Action_User_ProcessStarted = "- Proceso '{0}' iniciado."

    Error_User_LaunchMethodUnknown = "Método de lanzamiento '{0}' no reconocido. Opciones: direct, powershell, cmd."
    Error_User_InterpreterNotFound = "Intérprete '{0}' no encontrado para el método '{1}'."
    Error_User_ProcessManagementFailed = "Fallo en la gestión del proceso '{0}' (Método: '{1}', Ruta: '{2}', Args: '{3}'): '{4}'. StackTrace: '{5}'"
    Error_User_ExeNotFound = "Archivo ejecutable para el proceso '{0}' (modo directo) NO ENCONTRADO."
    Error_User_FatalScriptError = "ERROR FATAL DEL SCRIPT DE USUARIO '{0}': '{1}' \n'{2}'"
    Error_User_VarExpansionFailed = "Error al expandir las variables para el proceso '{0}': '{1}'"

    Action_User_CloseTaskConfigured = "- Cierre de la aplicación programado a las {1}."
    Error_User_CloseTaskFailed = "Fallo al crear la tarea de cierre de la aplicación '{0}': '{1}'"

    # ------------------------------------------------------------------------------
    # 4. MÓDULO DE COPIA DE SEGURIDAD (Invoke-DatabaseBackup.ps1)
    # ------------------------------------------------------------------------------
    Log_Backup_Starting = "Iniciando el proceso de copia de seguridad de las bases de datos..."
    Log_Backup_Disabled = "La copia de seguridad de la base de datos está DESACTIVADA en config.ini. Omitido."
    Log_Backup_PurgeStarting = "Iniciando la purga de copias de seguridad antiguas (conservando los últimos {0} días)..."
    Log_Backup_PurgingFile = "Purgando copia de seguridad antigua: '{0}'."
    Log_Backup_NoFilesToPurge = "No hay copias de seguridad antiguas para purgar."
    Log_Backup_RetentionPolicy = "Política de retención: {0} día(s)."
    Log_Backup_NoFilesFound = "No se encontraron archivos modificados en las últimas 24 horas para la copia de seguridad."
    Log_Backup_FilesFound = "{0} archivo(s) para respaldar encontrados (archivos emparejados incluidos)."
    Log_Backup_CopyingFile = "Copia de seguridad de '{0}' a '{1}' exitosa."
    Log_Backup_AlreadyRunning = "La copia de seguridad ya está en curso (antigüedad del bloqueo: {0} min). Omitido."

    Action_Backup_Completed = "Copia de seguridad de {0} archivo(s) completada con éxito."
    Action_Backup_DestinationCreated = "Carpeta de destino de la copia de seguridad '{0}' creada."
    Action_Backup_PurgeCompleted = "Purga de {0} copia(s) de seguridad antigua(s) completada."

    Error_Backup_PathNotFound = "La ruta de origen o destino '{0}' para la copia de seguridad no se encuentra. Operación cancelada."
    Error_Backup_DestinationCreationFailed = "Fallo al crear la carpeta de destino '{0}': '{1}'"
    Error_Backup_InsufficientPermissions = "Permisos insuficientes para escribir en la carpeta de copia de seguridad: '{0}'"
    Error_Backup_InsufficientSpace = "Espacio en disco insuficiente. Requerido: {0:N2} MB, Disponible: {1:N2} MB"
    Error_Backup_PurgeFailed = "Fallo al purgar la copia de seguridad antigua '{0}': '{1}'"
    Error_Backup_CopyFailed = "Fallo al respaldar el archivo '{0}': '{1}'"
    Error_Backup_Critical = "ERROR CRÍTICO durante el proceso de copia de seguridad: '{0}'"
    Backup_ConfigLoadError = "No se pudo leer config.ini"
    Backup_InitError = "Error crítico de inicialización: '{0}'"

    # ------------------------------------------------------------------------------
    # 5. INSTALACIÓN Y DESINSTALACIÓN (install.ps1 / uninstall.ps1)
    # ------------------------------------------------------------------------------

    # Común
    Install_ElevationWarning = "Fallo en la elevación de privilegios. Por favor, ejecute este script como administrador."
    Uninstall_ElevationWarning = "Fallo en la elevación de privilegios. Por favor, ejecute este script como administrador."
    Install_PressEnterToExit = "Presione Enter para salir."
    Uninstall_PressEnterToExit = "Presione Enter para salir."
    Install_PressEnterToClose = "Presione Enter para cerrar esta ventana."
    Uninstall_PressEnterToClose = "Presione Enter para cerrar esta ventana."
    Exit_AutoCloseMessage = "Esta ventana se cerrará en {0} segundos..."
    Install_RebootMessage = "Instalación completada. El sistema se reiniciará en {0} segundos para aplicar la configuración."
    Uninstall_RebootMessage = "Desinstalación completada. El sistema se reiniciará en {0} segundos para limpiar el entorno."

    # Instalación - Inicialización
    Install_UnsupportedArchitectureError = "Arquitectura de procesador no soportada: '{0}'"
    Install_ConfigIniNotFoundWarning = "config.ini no encontrado en el presunto directorio padre ('{0}')."
    Install_ProjectRootPrompt = "Por favor, introduzca la ruta completa al directorio raíz de los scripts de WindowsOrchestrator (ej: C:\WindowsOrchestrator)"
    Install_InvalidProjectRootError = "Directorio raíz del proyecto inválido o config.ini no encontrado: '{0}'"
    Install_PathDeterminationError = "Error al determinar las rutas iniciales: '{0}'"
    Install_MissingSystemFile = "Falta el archivo de sistema requerido: '{0}'"
    Install_MissingUserFile = "Falta el archivo de usuario requerido: '{0}'"
    Install_MissingFilesAborted = "Faltan archivos de script principales en '{0}'. Instalación cancelada. Presione Enter para salir."
    Install_ProjectRootUsed = "Directorio raíz del proyecto utilizado: '{0}'"
    Install_UserTaskTarget = "La tarea de usuario se instalará para: '{0}'"
    Install_AutoLoginUserEmpty = "INFO: 'AutoLoginUsername' está vacío. Rellenando con el usuario instalador..."
    Install_AutoLoginUserUpdated = "ÉXITO: config.ini actualizado con 'AutoLoginUsername={0}'."
    Install_AutoLoginUserUpdateFailed = "ADVERTENCIA: Fallo al actualizar 'AutoLoginUsername' en config.ini: '{0}'"
    Install_LogPermissionsWarning = "ADVERTENCIA: No se pudieron crear o establecer los permisos para la carpeta Logs. El registro podría fallar. Error: '{0}'"

    # Instalación - Asistente de Autologon
    Install_AutologonAlreadyActive = "INFO: El inicio de sesión automático de Windows ya está activo. El asistente no es necesario."
    Install_DownloadingAutologon = "Descargando la herramienta Microsoft Autologon..."
    Install_AutologonDownloadFailed = "ERROR: Fallo al descargar Autologon.zip. Verifique su conexión a internet."
    Install_ExtractingArchive = "Extrayendo el archivo..."
    Install_AutologonFilesMissing = "Los archivos requeridos ('{0}', Eula.txt) no se encontraron después de la extracción."
    Install_AutologonExtractionFailed = "ADVERTENCIA: Fallo al preparar la herramienta Autologon. El archivo descargado puede estar dañado."
    Install_AutologonDownloadFailedPrompt = "La descarga falló. ¿Desea buscar el archivo Autologon.zip manualmente?\n\nPágina oficial: https://learn.microsoft.com/sysinternals/downloads/autologon"
    Install_AutologonUnsupportedArchitecture = "ERROR: Arquitectura de procesador no soportada ('{0}'). No se puede configurar Autologon."
    Install_EulaConsentMessage = "¿Acepta los términos de la licencia de la herramienta Autologon de Sysinternals?"
    Install_EulaConsentCaption = "Se requiere consentimiento del EULA"
    Install_PromptReviewEula = "El Contrato de Licencia de Usuario Final (EULA) de Microsoft se abrirá en el Bloc de notas. Por favor, léalo y cierre la ventana para continuar."
    Install_EulaConsentRefused = "El consentimiento de la licencia fue denegado por el usuario. Configuración de Autologon cancelada."
    Install_EulaRejected = "Configuración de Autologon cancelada (EULA no aceptado)."
    Install_PromptUseAutologonTool = "La herramienta Autologon se abrirá ahora. Por favor, introduzca su información (Usuario, Dominio, Contraseña) y haga clic en 'Enable'."
    Install_AutologonSelectZipTitle = "Seleccione el archivo Autologon.zip descargado"
    Install_AutologonFileSelectedSuccess = "ÉXITO: Se utilizará el archivo local '{0}'."
    Install_AutologonSuccess = "ÉXITO: La herramienta Autologon se ha ejecutado. El inicio de sesión automático debería estar configurado ahora."
    Install_ContinueNoAutologon = "La instalación continúa sin configurar Autologon."
    Install_AbortedByUser = "Instalación cancelada por el usuario."
    Install_AutologonDownloadFailedCaption = "Asistente de Autologon fallido"
    Install_ConfirmContinueWithoutAutologon = "El asistente de Autologon ha fallado. ¿Desea continuar la instalación sin el inicio de sesión automático?"
    Install_AutologonManualDownloadPrompt = @"
La descarga automática de la herramienta Autologon ha fallado.

Puede descargarla manualmente para activar esta función.

1.  Abra esta URL en su navegador: https://learn.microsoft.com/sysinternals/downloads/autologon
2.  Descargue y extraiga 'Autologon.zip'.
3.  Coloque todos los archivos extraídos (Autologon64.exe, etc.) en la siguiente carpeta:
    {0}
4.  Vuelva a ejecutar la instalación.

¿Desea continuar la instalación ahora sin configurar Autologon?
"@

    # Instalación - Contraseña y Tareas
    Install_PasswordRequiredPrompt = "El modo de sesión automática está activado. Se REQUIERE la contraseña de la cuenta '{0}' para configurar la tarea programada de forma segura."
    Install_PasswordSecurityInfo = "Esta contraseña se pasa directamente a la API de Windows y NUNCA se almacena."
    Install_EnterPasswordPrompt = "Por favor, introduzca la contraseña para la cuenta '{0}'"
    Install_PasswordIncorrect = "Contraseña incorrecta o error de validación. Por favor, inténtelo de nuevo."
    Install_PasswordAttemptsRemaining = "Intentos restantes: {0}."
    Install_PasswordEmptyToCancel = "(Deje en blanco y presione Enter para cancelar)"
    Install_PasswordMaxAttemptsReached = "Se alcanzó el número máximo de intentos. Instalación cancelada."
    Install_StartConfiguringTasks = "Iniciando la configuración de las tareas programadas..."
    Install_CreatingSystemTask = "Creando/Actualizando la tarea del sistema '{0}'..."
    Install_SystemTaskDescription = "WindowsOrchestrator: Ejecuta el script de configuración del sistema al inicio."
    Install_SystemTaskConfiguredSuccess = "Tarea '{0}' configurada con éxito."
    Install_CreatingUserTask = "Creando/Actualizando la tarea de usuario '{0}' para '{1}'..."
    Install_UserTaskDescription = "WindowsOrchestrator: Ejecuta el script de configuración de usuario al iniciar sesión."
    Install_MainTasksConfigured = "Tareas programadas principales configuradas."
    Install_DailyRebootTasksNote = "Las tareas para el reinicio diario y la acción de cierre serán gestionadas por '{0}' durante su ejecución."
    Install_TaskCreationSuccess = "Tareas creadas con éxito utilizando las credenciales proporcionadas."

    # Instalación - Ejecución y Fin
    Install_AttemptingInitialLaunch = "Intentando el lanzamiento inicial de los scripts de configuración..."
    Install_ExecutingSystemScript = "Ejecutando config_systeme.ps1 para aplicar las configuraciones iniciales del sistema..."
    Install_SystemScriptSuccess = "config_systeme.ps1 ejecutado con éxito (código de salida 0)."
    Install_SystemScriptWarning = "config_systeme.ps1 finalizó con un código de salida: {0}. Verifique los registros en '{1}\Logs'."
    Install_SystemScriptError = "Error durante la ejecución inicial de config_systeme.ps1: '{0}'"
    Install_Trace = "Traza: '{0}'"
    Install_ExecutingUserScript = "Ejecutando config_utilisateur.ps1 para '{0}' para aplicar las configuraciones iniciales del usuario..."
    Install_UserConfigLaunched = "ÉXITO: El script de configuración de usuario ha sido lanzado."
    Install_UserScriptSuccess = "config_utilisateur.ps1 ejecutado con éxito para '{0}' (código de salida 0)."
    Install_UserScriptWarning = "config_utilisateur.ps1 para '{0}' finalizó con un código de salida: '{1}'. Verifique los registros en '{2}\Logs'."
    Install_UserScriptError = "Error durante la ejecución inicial de config_utilisateur.ps1 para '{0}': '{1}'"
    Install_InstallationCompleteSuccess = "¡Instalación y lanzamiento inicial completados!"
    Install_InstallationCompleteWithErrors = "Instalación completada con errores durante el lanzamiento inicial de los scripts. Verifique los mensajes anteriores."
    Install_CriticalErrorDuringInstallation = "Ocurrió un error crítico durante la instalación: '{0}'"
    Install_SilentMode_CompletedSuccessfully = "¡Instalación de WindowsOrchestrator completada con éxito!\n\nTodos los registros se han guardado en la carpeta Logs."
    Install_SilentMode_CompletedWithErrors = "Instalación de WindowsOrchestrator completada con errores.\n\nPor favor, consulte los archivos de registro en la carpeta Logs para más detalles."

    # Desinstalación
    Uninstall_StartMessage = "Iniciando la desinstalación completa de WindowsOrchestrator..."
    Uninstall_AutoLogonQuestion = "[PREGUNTA] WindowsOrchestrator puede haber activado el inicio de sesión automático (Autologon). ¿Desea desactivarlo ahora? (s/n)"
    Uninstall_RestoringSettings = "Restaurando la configuración principal de Windows..."
    Uninstall_WindowsUpdateReactivated = "- Actualizaciones de Windows y reinicio automático: Reactivados."
    Uninstall_WindowsUpdateError = "- ERROR al reactivar Windows Update: '{0}'"
    Uninstall_FastStartupReactivated = "- Inicio rápido de Windows: Reactivado (valor predeterminado)."
    Uninstall_FastStartupError = "- ERROR al reactivar el inicio rápido: '{0}'"
    Uninstall_OneDriveReactivated = "- OneDrive: Reactivado (política de bloqueo eliminada)."
    Uninstall_OneDriveError = "- ERROR al reactivar OneDrive: '{0}'"
    Uninstall_DeletingScheduledTasks = "Eliminando las tareas programadas..."
    Uninstall_ProcessingTask = "Procesando la tarea '{0}'..."
    Uninstall_TaskFoundAttemptingDeletion = " Encontrada. Intentando eliminar..."
    Uninstall_TaskSuccessfullyRemoved = " Eliminada con éxito."
    Uninstall_TaskDeletionFailed = " FALLO al eliminar."
    Uninstall_TaskDeletionError = " ERROR al eliminar."
    Uninstall_TaskErrorDetail = "   Detalle: '{0}'"
    Uninstall_TaskNotFound = " No encontrada."
    Uninstall_CompletionMessage = "Desinstalación completada."
    Uninstall_TasksNotRemovedWarning = "Algunas tareas NO pudieron ser eliminadas: '{0}'."
    Uninstall_CheckTaskScheduler = "Por favor, verifique el Programador de Tareas."
    Uninstall_FilesNotDeletedNote = "Nota: Los scripts y archivos de configuración no se eliminan de su disco."
    Uninstall_LSACleanAttempt = "INFO: Intentando una limpieza completa de los secretos LSA a través de Autologon.exe..."
    Uninstall_AutoLogonDisabled = "- Inicio de sesión automático: Desactivado (a través de la herramienta Autologon)."
    Uninstall_AutoLogonDisableError = "- ERROR al intentar desactivar el inicio de sesión automático: '{0}'"
    Uninstall_AutoLogonLeftAsIs = "- Inicio de sesión automático: Dejado como está (elección del usuario)."
    Uninstall_AutologonToolNotFound_Interactive = "[ADVERTENCIA] La herramienta Autologon.exe no se encuentra. La desactivación automática no se puede realizar. Si desea desactivar el inicio de sesión automático, hágalo manualmente."
    Uninstall_AutologonDisablePrompt = "Por favor, haga clic en 'Disable' (Disable) en la ventana de la herramienta Autologon que se abrirá para finalizar la limpieza."
    Uninstall_AutologonNotActive = "INFO: El inicio de sesión automático no está activo. No se necesita limpieza."
    Uninstall_SilentMode_CompletedSuccessfully = "¡Desinstalación de WindowsOrchestrator completada con éxito!\n\nTodos los registros se han guardado en la carpeta Logs."
    Uninstall_SilentMode_CompletedWithErrors = "Desinstalación de WindowsOrchestrator completada con errores.\n\nPor favor, consulte los archivos de registro en la carpeta Logs para más detalles."

    # ------------------------------------------------------------------------------
    # 6. NOTIFICACIONES (Gotify) Y COMUNES
    # ------------------------------------------------------------------------------
    Gotify_MessageDate = "Ejecutado el {0}."
    Gotify_SystemActionsHeader = "Acciones del SISTEMA:"
    Gotify_NoSystemActions = "Ninguna acción del SISTEMA."
    Gotify_SystemErrorsHeader = "Errores del SISTEMA:"
    Gotify_UserActionsHeader = "Acciones del USUARIO:"
    Gotify_NoUserActions = "Ninguna acción del USUARIO."
    Gotify_UserErrorsHeader = "Errores del USUARIO:"
    Error_LanguageFileLoad = "Ocurrió un error crítico al cargar los archivos de idioma: '{0}'"
    Error_InvalidConfigValue = "Valor de configuración inválido para [{0}]{1}: '{2}'. Tipo esperado '{3}'. Se utiliza el valor predeterminado/vacío."
    Install_SplashMessage = "Operación en curso, por favor espere..."
}
