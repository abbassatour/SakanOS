[Setup]
AppId={{D8E5F3B2-7A6C-4B9F-8D1E-123456789ABC}
AppName=Our Home ERP
AppVersion=1.0.0
AppPublisher=Your Company Name
DefaultDirName={autopf}\Our Home ERP
DefaultGroupName=Our Home ERP

; البناء المتوافق مع أنظمة 64 بت العادية والحديثة ARM64
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible

OutputDir=C:\Users\DELL\Desktop
OutputBaseFilename=our_home_erp_setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
; الملف التنفيذي الرئيسي لبناء Flutter
Source: "C:\Users\DELL\Desktop\our_home_erp_app\build\windows\x64\runner\Release\our_home_erp_app.exe"; DestDir: "{app}"; Flags: ignoreversion

; تضمين حزمة C++ ليتم فكها مؤقتاً أثناء التثبيت
Source: "C:\Users\DELL\Desktop\our_home_erp_app\Redist\vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

; تضمين باقي الملفات والمجلدات المرافقة له
Source: "C:\Users\DELL\Desktop\our_home_erp_app\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "our_home_erp_app.exe"

[Icons]
Name: "{group}\Our Home ERP"; Filename: "{app}\our_home_erp_app.exe"
Name: "{autodesktop}\Our Home ERP"; Filename: "{app}\our_home_erp_app.exe"; Tasks: desktopicon

[Run]
; تشغيل مثبت حزمة C++ صامتاً في الخلفية قبل انتهاء تثبيت تطبيقك
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/quiet /norestart"; StatusMsg: "Installing Microsoft Visual C++ Redistributable..."; Flags: waituntilterminated

; خيار تشغيل البرنامج فور انتهاء التثبيت
Filename: "{app}\our_home_erp_app.exe"; Description: "{cm:LaunchProgram,Our Home ERP}"; Flags: nowait postinstall skipifsilent