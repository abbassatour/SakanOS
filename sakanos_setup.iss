; =====================================================================
;  SakanOS Real Estate ERP - Inno Setup Script
;  Engineered for Flutter Windows Release Builds (x64)
; =====================================================================

#define MyAppName        "SakanOS"
#define MyAppVersion     "1.0.0"
#define MyAppPublisher   "SakanOS Team"
#define MyAppURL         "https://github.com/your-username/our_home_erp_app"
#define MyAppExeName     "our_home_erp_app.exe"
#define MyAppId          "{A78C56B2-39E4-4D2A-B982-5C68E9B61E42}"

; Relative path to Flutter Windows Release output directory
#define MyAppSourcePath  "build\windows\x64\runner\Release"

[Setup]
; --- Unique Identity & App Information ---
AppId={{#MyAppId}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} v{#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}

; --- Installation Directories & Privileges ---
; Allows standard user installs or administrative overrides
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=commandline dialog

; --- Architecture Settings (Flutter Windows requires 64-bit) ---
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

; --- Output Configuration ---
OutputDir=Output
OutputBaseFilename=SakanOS_Setup_v{#MyAppVersion}_x64
SetupIconFile=windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}

; --- Compression & Performance ---
Compression=lzma2/ultra64
SolidCompression=yes
LZMAUseSeparateProcess=yes
LZMADictionarySize=1048576

; --- Modern UI & Behavior ---
WizardStyle=modern
WizardSizePercent=100
DisableProgramGroupPage=auto
CloseApplications=yes
RestartApplications=no
DisableWelcomePage=no

; =====================================================================
;  Multi-Language Support (Arabic & English)
; =====================================================================
[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "arabic";  MessagesFile: "compiler:Languages\Arabic.isl"

[CustomMessages]
english.CreateDesktopIcon=Create a &desktop shortcut
arabic.CreateDesktopIcon=إنشاء اختصار على &سطح المكتب
english.LaunchApp=Launch SakanOS
arabic.LaunchApp=تشغيل نظام SakanOS

; =====================================================================
;  User Tasks
; =====================================================================
[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

; =====================================================================
;  Files & Bundled Assets
; =====================================================================
[Files]
; Primary Executable
Source: "{#MyAppSourcePath}\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion

; All bundled libraries, Flutter engines, DLLs, and application data
Source: "{#MyAppSourcePath}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "{#MyAppExeName}"

; =====================================================================
;  Shortcuts & Start Menu
; =====================================================================
[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\{#MyAppExeName}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

; =====================================================================
;  Post-Installation Launch
; =====================================================================
[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchApp}"; Flags: nowait postinstall skipifsilent

; =====================================================================
;  Uninstallation Cleanup
; =====================================================================
[UninstallDelete]
Type: filesandordirs; Name: "{app}\data"
Type: filesandordirs; Name: "{app}\logs"