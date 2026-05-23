[Setup]
; معرف التطبيق الفريد (مهم جداً للتحديثات - سنشرحه بالأسفل)
AppId={{D8E5F3B2-7A6C-4B9F-8D1E-123456789ABC}
AppName=Our Home ERP
AppVersion=1.0.0
AppPublisher=Your Company Name
DefaultDirName={autopf}\Our Home ERP
DefaultGroupName=Our Home ERP
; مكان حفظ ملف الـ Setup النهائي بعد تجميعه (مثلاً على سطح المكتب لديك)
OutputDir=C:\Users\DELL\Desktop
OutputBaseFilename=our_home_erp_setup
Compression=lzma
SolidCompression=yes
WizardStyle=modern

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
; هذه المهمة تظهر للمستخدم كخيار لوضع اختصار على سطح المكتب (مفعلة تلقائياً)
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
; 1. الملف التنفيذي الرئيسي بناءً على مسارك
Source: "C:\Users\DELL\Desktop\our_home_erp_app\build\windows\x64\runner\Release\our_home_erp_app.exe"; DestDir: "{app}"; Flags: ignoreversion

; 2. تضمين باقي الملفات والمجلدات المرافقة له (مثل مجلد data وملفات الـ dll) باستثناء الملف التنفيذي نفسه لتجنب التكرار
Source: "C:\Users\DELL\Desktop\our_home_erp_app\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "our_home_erp_app.exe"

[Icons]
; اختصار البرنامج في قائمة ابدأ
Name: "{group}\Our Home ERP"; Filename: "{app}\our_home_erp_app.exe"
; اختصار البرنامج على سطح المكتب (يرتبط بالمهمة المذكورة في قسم Tasks أعلاه)
Name: "{autodesktop}\Our Home ERP"; Filename: "{app}\our_home_erp_app.exe"; Tasks: desktopicon

[Run]
; خيار تشغيل البرنامج فور انتهاء التثبيت
Filename: "{app}\our_home_erp_app.exe"; Description: "{cm:LaunchProgram,Our Home ERP}"; Flags: nowait postinstall skipifsilent