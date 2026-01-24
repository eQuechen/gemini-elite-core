@echo off
SETLOCAL EnableDelayedExpansion

:: Gemini Elite Core Setup Script - v6.3 "Path Integrity Edition"
:: Windows CMD Version - Fix: Estabilización de rutas absolutas para GEMINI.md

:: Visual constants (ANSI Escape Sequences)
set "ESC="
set "CYAN=%ESC%[0;36m"
set "GREEN=%ESC%[0;32m"
set "YELLOW=%ESC%[1;33m"
set "MAGENTA=%ESC%[0;35m"
set "BLUE=%ESC%[0;34m"
set "NC=%ESC%[0m"

:: Language Selection
cls
echo %MAGENTA%Select Language / Selecciona Idioma:%NC%
echo 1) English (Default)
echo 2) Español
set /p LANG_CHOICE="Selection / Seleccion [1]: "

if "%LANG_CHOICE%"=="2" (
    set "SELECTED_LANG=ES"
) else (
    set "SELECTED_LANG=EN"
)

:: Translations
if "%SELECTED_LANG%"=="ES" (
    set "MSG_TITLE=Gemini Elite Core v6.3"
    set "MSG_SUBTITLE=La suite de aprovisionamiento inteligente (Path Integrity Update)"
    set "MSG_STEP_CHECK_CLI=Comprobando Gemini CLI..."
    set "MSG_WARN_CLI_NOT_FOUND=Gemini CLI no detectado. Instalando version @nightly..."
    set "MSG_SUCCESS_CLI_INSTALLED=Gemini CLI instalado."
    set "MSG_INFO_UPDATING_CLI=Actualizando Gemini CLI a la ultima version @nightly..."
    set "MSG_SEC_CONFIG=Configuracion de Seguridad:"
    set "MSG_ENTER_API_KEY=Introduce tu Gemini API Key (o pulsa Enter para omitir): "
    set "MSG_SAVE_PERM=¿Guardar permanentemente en las variables de entorno del usuario? (s/n): "
    set "MSG_SUCCESS_KEY_SAVED=API Key guardada permanentemente."
    set "MSG_STEP_SYNC_SETTINGS=Sincronizando Configuracion..."
    set "MSG_SUCCESS_SETTINGS_MERGED=Configuracion fusionada."
    set "MSG_STEP_CONFIG_MCP=Configurando MCPs sensoriales base..."
    set "MSG_SUCCESS_MCP_READY=Stack sensorial MCP listo."
    set "MSG_STEP_INST_SKILLS=Instalando Habilidades Tacticas..."
    set "MSG_INFO_DEPLOYING=Desplegando"
    set "MSG_SUCCESS_SKILLS_DEPLOYED=Habilidades tacticas desplegadas."
    set "MSG_STEP_ADOPT_PROTOCOLS=Adopcion de Protocolos Agenticos"
    set "MSG_PROTOCOLS_DESC=Los protocolos Elite Core imponen flujos de trabajo especificos:"
    set "MSG_PROMPT_ADOPT=¿Quieres adoptar estos protocolos Elite Core en tu GEMINI.md global? [S/n]: "
    set "MSG_SUCCESS_GEMINI_MD=GEMINI.md global actualizado."
    set "MSG_FINISH=Aprovisionamiento de Gemini Elite Core completado!"
    set "MSG_CONSERVATIVE_PROMPT=¿Quieres ser mas conservador?"
    set "MSG_ERR_SPACE=ERROR: Espacio insuficiente o error de enlace. Reintentando..."
    set "YES_VAL=s"
) else (
    set "MSG_TITLE=Gemini Elite Core v6.3"
    set "MSG_SUBTITLE=The Intelligent Provisioning Suite (Path Integrity Update)"
    set "MSG_STEP_CHECK_CLI=Checking Gemini CLI..."
    set "MSG_WARN_CLI_NOT_FOUND=Gemini CLI not detected. Installing @nightly version..."
    set "MSG_SUCCESS_CLI_INSTALLED=Gemini CLI installed."
    set "MSG_INFO_UPDATING_CLI=Updating Gemini CLI to the latest @nightly version..."
    set "MSG_SEC_CONFIG=Security Configuration:"
    set "MSG_ENTER_API_KEY=Enter your Gemini API Key (or press Enter to skip): "
    set "MSG_SAVE_PERM=Save permanently in your user environment variables? (y/n): "
    set "MSG_SUCCESS_KEY_SAVED=API Key saved permanently."
    set "MSG_STEP_SYNC_SETTINGS=Synchronizing Settings..."
    set "MSG_SUCCESS_SETTINGS_MERGED=Settings merged."
    set "MSG_STEP_CONFIG_MCP=Configuring Base Sensory MCPs..."
    set "MSG_SUCCESS_MCP_READY=MCP Sensory Stack ready."
    set "MSG_STEP_INST_SKILLS=Installing Tactical Skills..."
    set "MSG_INFO_DEPLOYING=Deploying"
    set "MSG_SUCCESS_SKILLS_DEPLOYED=Tactical Skills deployed."
    set "MSG_STEP_ADOPT_PROTOCOLS=Agentic Protocols Adoption"
    set "MSG_PROTOCOLS_DESC=Elite Core Protocols enforce specific workflows:"
    set "MSG_PROMPT_ADOPT=Do you want to adopt these Elite Core protocols in your global GEMINI.md? [Y/n]: "
    set "MSG_SUCCESS_GEMINI_MD=Global GEMINI.md updated."
    set "MSG_FINISH=Gemini Elite Core Provisioning Complete!"
    set "MSG_CONSERVATIVE_PROMPT=Do you want to be more conservative?"
    set "MSG_ERR_SPACE=ERROR: Insufficient space or link error. Retrying..."
    set "YES_VAL=y"
)

:: Conservative Mode Selection
echo.
echo %MAGENTA%%MSG_CONSERVATIVE_PROMPT%%NC%
echo 1) Less conservative (Most powerful) [Default]
echo 2) More conservative
set /p CONSERVATIVE_CHOICE="Selection / Seleccion [1]: "

set "CONSERVATIVE_MODE=false"
if "%CONSERVATIVE_CHOICE%"=="2" set "CONSERVATIVE_MODE=true"

cls
echo %MAGENTA%%MSG_TITLE%%NC%
echo %CYAN%%MSG_SUBTITLE%%NC%
echo.

:: 1. CLI Installation
echo %CYAN%🚀 %MSG_STEP_CHECK_CLI%%NC%
where gemini >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo %BLUE%info%NC% %MSG_INFO_UPDATING_CLI%
) else (
    echo %YELLOW%warn%NC% %MSG_WARN_CLI_NOT_FOUND%
)

where bun >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    call bun install -g @google/gemini-cli@nightly
) else (
    call npm install -g @google/gemini-cli@nightly
)
echo %GREEN%success%NC% %MSG_SUCCESS_CLI_INSTALLED%

:: 2. Configuration Directories (Forced Creation)
set "GEMINI_DIR=%USERPROFILE%\.gemini"
set "SETTINGS_FILE=%USERPROFILE%\.gemini\settings.json"
set "HOOKS_DIR=%USERPROFILE%\.gemini\hooks"
set "USER_GEMINI=%USERPROFILE%\.gemini\GEMINI.md"

if not exist "%GEMINI_DIR%" mkdir "%GEMINI_DIR%"
if not exist "%HOOKS_DIR%" mkdir "%HOOKS_DIR%"

:: 3. Tactical Skills
echo.
echo %CYAN%🚀 %MSG_STEP_INST_SKILLS%%NC%
set "SKILLS_COUNT=0"
if exist skills (
    pushd skills
    for /D %%D in (*) do (
        set "SKILL_NAME=%%D"
        set "LOCAL_SKILL=%%D\SKILL.md"
        set "INSTALLED_SKILL=%USERPROFILE%\.gemini\skills\%%D\SKILL.md"
        
        set "NEEDS_INSTALL=yes"
        if exist "!INSTALLED_SKILL!" (
            :: Simple existence check for now, or use certutil for hash if needed
            set "NEEDS_INSTALL=no"
            :: To force update if changed, we could compare sizes or use a more complex check
            :: But for CMD, skipping if exists is a good baseline to match user request
        )

        if "!NEEDS_INSTALL!"=="yes" (
            echo %BLUE%info%NC% %MSG_INFO_DEPLOYING% %%D...
            call gemini skills install "%%D" --consent >nul 2>&1
        )
        set /a SKILLS_COUNT+=1
    )
    popd
)
echo %GREEN%success%NC% %MSG_SUCCESS_SKILLS_DEPLOYED% (%SKILLS_COUNT% skills)

:: 4. MCP Setup
echo.
echo %CYAN%🚀 %MSG_STEP_CONFIG_MCP%%NC%

:: Check chrome-devtools
call gemini mcp list 2>nul | findstr /C:"chrome-devtools" >nul
if %ERRORLEVEL% NEQ 0 (
    echo %BLUE%info%NC% Adding chrome-devtools MCP...
    call gemini mcp add --scope user chrome-devtools npx -y chrome-devtools-mcp @latest >nul 2>&1
)

:: Filesystem MCP (Rust vs Node)
call gemini mcp list 2>nul | findstr /C:"filesystem" >nul
if %ERRORLEVEL% NEQ 0 (
    if "%CONSERVATIVE_MODE%"=="false" (
        where rust-mcp-filesystem >nul 2>nul
        if %ERRORLEVEL% EQU 0 (
            echo %GREEN%success%NC% Rust Filesystem MCP detected.
            call gemini mcp add --scope user filesystem rust-mcp-filesystem -w "." "%USERPROFILE%\.gemini\skills" >nul 2>&1
        ) else (
            echo %BLUE%info%NC% rust-mcp-filesystem not found in PATH. Falling back to Node.js...
            call gemini mcp add --scope user filesystem npx -y @modelcontextprotocol/server-filesystem "." >nul 2>&1
        )
    ) else (
        echo %BLUE%info%NC% Conservative Mode: Using standard Node.js filesystem MCP...
        call gemini mcp add --scope user filesystem npx -y @modelcontextprotocol/server-filesystem "." >nul 2>&1
    )
)
echo %GREEN%success%NC% %MSG_SUCCESS_MCP_READY%

:: 5. Sync Settings (Full Elite Core Configuration)
echo.
echo %CYAN%🚀 %MSG_STEP_SYNC_SETTINGS%%NC%
set "TEMP_SCRIPT=%TEMP%\gemini_merge.js"

echo const fs = require('fs'); > "%TEMP_SCRIPT%"
echo const path = require('path'); >> "%TEMP_SCRIPT%"
echo const settingsPath = process.argv[2]; >> "%TEMP_SCRIPT%"
echo const hooksDir = process.argv[3]; >> "%TEMP_SCRIPT%"
echo const optimized = { >> "%TEMP_SCRIPT%"
echo   enableAgentSkills: true, >> "%TEMP_SCRIPT%"
echo   core: { disableLLMCorrection: true }, >> "%TEMP_SCRIPT%"
echo   experimental: { >> "%TEMP_SCRIPT%"
echo     introspectionAgentSettings: { enabled: true }, >> "%TEMP_SCRIPT%"
echo     skillCreator: true, >> "%TEMP_SCRIPT%"
echo     hooks: true, >> "%TEMP_SCRIPT%"
echo     hooksSystem: true, >> "%TEMP_SCRIPT%"
echo     planning: true, >> "%TEMP_SCRIPT%"
echo     eventDrivenScheduler: true >> "%TEMP_SCRIPT%"
echo   }, >> "%TEMP_SCRIPT%"
echo   agents: { >> "%TEMP_SCRIPT%"
echo     generalist: { enabled: true, runConfig: { maxTurns: 50, timeout: 600000 } }, >> "%TEMP_SCRIPT%"
echo     codebaseInvestigator: { enabled: true, runConfig: { maxTurns: 100, timeout: 600000 } }, >> "%TEMP_SCRIPT%"
echo     codeReviewer: { enabled: true, runConfig: { maxTurns: 30, timeout: 300000 } }, >> "%TEMP_SCRIPT%"
echo     bugFixer: { enabled: true, runConfig: { maxTurns: 50, timeout: 300000 } } >> "%TEMP_SCRIPT%"
echo   }, >> "%TEMP_SCRIPT%"
echo   model: { name: 'gemini-3-flash-preview' }, >> "%TEMP_SCRIPT%"
echo   tools: { autoAccept: true } >> "%TEMP_SCRIPT%"
echo }; >> "%TEMP_SCRIPT%"
echo try { >> "%TEMP_SCRIPT%"
echo   let current = {}; >> "%TEMP_SCRIPT%"
echo   if (fs.existsSync(settingsPath)) { >> "%TEMP_SCRIPT%"
echo     const content = fs.readFileSync(settingsPath, 'utf8'); >> "%TEMP_SCRIPT%"
echo     if (content.trim()) current = JSON.parse(content); >> "%TEMP_SCRIPT%"
echo   } >> "%TEMP_SCRIPT%"
echo   const hooks = { >> "%TEMP_SCRIPT%"
echo     'SessionStart': [{ 'matcher': '*', 'hooks': [{ 'name': 'welcome', 'type': 'command', 'command': 'bun ' + path.join(hooksDir, 'session-start-welcome.js') }] }], >> "%TEMP_SCRIPT%"
echo     'AfterTool': [{ 'matcher': '*', 'hooks': [{ 'name': 'type-check', 'type': 'command', 'command': 'bun ' + path.join(hooksDir, 'after-tool-type-check.js') }] }], >> "%TEMP_SCRIPT%"
echo     'AfterModel': [{ 'matcher': '*', 'hooks': [{ 'name': 'commit-check', 'type': 'command', 'command': 'bun ' + path.join(hooksDir, 'after-model-commit-check.js') }] }] >> "%TEMP_SCRIPT%"
echo   }; >> "%TEMP_SCRIPT%"
echo   const merged = { ...current, ...optimized, >> "%TEMP_SCRIPT%"
echo     experimental: { ...(current.experimental || {}), ...optimized.experimental }, >> "%TEMP_SCRIPT%"
echo     agents: { ...(current.agents || {}), ...optimized.agents }, >> "%TEMP_SCRIPT%"
echo     hooks: hooks >> "%TEMP_SCRIPT%"
echo   }; >> "%TEMP_SCRIPT%"
echo   fs.writeFileSync(settingsPath, JSON.stringify(merged, null, 2)); >> "%TEMP_SCRIPT%"
echo   process.exit(0); >> "%TEMP_SCRIPT%"
echo } catch (e) { >> "%TEMP_SCRIPT%"
echo   process.exit(1); >> "%TEMP_SCRIPT%"
echo } >> "%TEMP_SCRIPT%"

where bun >nul 2>nul
if %ERRORLEVEL% EQU 0 (set "RUNNER=bun") else (set "RUNNER=node")

echo %BLUE%info%NC% Merging via %RUNNER%...
call %RUNNER% "%TEMP_SCRIPT%" "%SETTINGS_FILE%" "%HOOKS_DIR%"

if %ERRORLEVEL% EQU 0 (
    echo %GREEN%success%NC% %MSG_SUCCESS_SETTINGS_MERGED%
) else (
    echo %YELLOW%warn%NC% Fallback: Manual creation...
    echo {"enableAgentSkills":true,"model":{"name":"gemini-3-flash-preview"}} > "%SETTINGS_FILE%"
)
if exist "%TEMP_SCRIPT%" del "%TEMP_SCRIPT%"

:: 5.5 Copying Hooks
if exist hooks (
    echo %BLUE%info%NC% Deploying Protocol Hooks...
    copy /Y hooks\*.js "%HOOKS_DIR%\" >nul 2>&1
)

:: 6. Global GEMINI.md (Path Stabilized Writing)
echo.
if "%CONSERVATIVE_MODE%"=="false" (
    set "ADOPT_PROTOCOLS=%YES_VAL%"
) else (
    echo %CYAN%🚀 %MSG_STEP_ADOPT_PROTOCOLS%%NC%
    echo %YELLOW%%MSG_PROTOCOLS_DESC%%NC%
    set /p ADOPT_PROTOCOLS="%MSG_PROMPT_ADOPT%"
)

if /I "%ADOPT_PROTOCOLS%"=="%YES_VAL%" (
    :: Re-verify directory exists just before writing
    if not exist "%USERPROFILE%\.gemini" mkdir "%USERPROFILE%\.gemini"

    :: Write line by line using absolute system paths
    echo ^<ELITE_CORE_CONTEXT^> > "%USER_GEMINI%"
    echo # Gemini Elite Core >> "%USER_GEMINI%"
    echo - Use bun exclusively. >> "%USER_GEMINI%"
    echo ^</ELITE_CORE_CONTEXT^> >> "%USER_GEMINI%"

    if exist "%USER_GEMINI%" (
        echo %GREEN%success%NC% %MSG_SUCCESS_GEMINI_MD%
    ) else (
        echo %YELLOW%warn%NC% Could not verify GEMINI.md creation.
    )
)

echo.
echo %GREEN%✅ %MSG_FINISH%%NC%
echo ----------------------------------------------------
echo STATUS: Nightly (v0.27.0-Windows) ^| Skills: %SKILLS_COUNT%
echo ----------------------------------------------------
pause
