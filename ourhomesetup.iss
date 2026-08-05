[Setup]
; ⚠️ هام جداً: لا تقم بتغيير هذا الـ AppId أبداً في المستقبل، فهو يخبر ويندوز أن التحديثات تابعة لنفس البرنامج
AppId={{D8E5F3B2-7A6C-4B9F-8D1E-123456789ABC}
AppName=Our Home ERP
AppVersion=1.0.0
AppPublisher=Our Home Real Estate 
DefaultDirName={autopf}\Our Home ERP
DefaultGroupName=Our Home ERP

; 🌟 1. تم تحويل المسارات إلى مسارات نسبية (تعمل على أي جهاز)
SetupIconFile=windows\runner\resources\app_icon.ico
OutputDir=Output
OutputBaseFilename=OurHomeERP_Setup_v1.0.0

; فرض الصلاحيات والمعمارية (هذا الجزء لديك كان ممتازاً)
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

Compression=lzma2
SolidCompression=yes
WizardStyle=modern
; 🌟 إضافة دعم اليمين لليسار (RTL) في المثبت
RightToLeft=yes 

[Languages]
; 🌟 2. تم إضافة اللغة العربية
Name: "arabic"; MessagesFile: "compiler:Languages\Arabic.isl"
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"

[Files]
; 🌟 3. المسارات النسبية للملفات المترجمة
Source: "build\windows\x64\runner\Release\our_home_erp_app.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "our_home_erp_app.exe"

; حزمة C++ (يجب أن يكون مجلد Redist داخل مجلد المشروع)
Source: "Redist\vc_redist.x64.exe"; DestDir: "{tmp}"; Flags: deleteafterinstall

[Icons]
Name: "{group}\Our Home ERP"; Filename: "{app}\our_home_erp_app.exe"
Name: "{autodesktop}\Our Home ERP"; Filename: "{app}\our_home_erp_app.exe"; Tasks: desktopicon

[Run]
; 🌟 4. السطر السحري: Check: not IsVCRedistInstalled (لن يثبتها إلا إذا لم تكن موجودة)
Filename: "{tmp}\vc_redist.x64.exe"; Parameters: "/passive /norestart"; StatusMsg: "جاري تثبيت حزم مايكروسوفت الأساسية (Visual C++)..."; Check: not IsVCRedistInstalled; Flags: waituntilterminated

Filename: "{app}\our_home_erp_app.exe"; Description: "{cm:LaunchProgram,Our Home ERP}"; Flags: nowait postinstall skipifsilent

; ==========================================
; 🌟 5. كود الفحص الذكي (Pascal Script)
; ==========================================
[Code]
function IsVCRedistInstalled: Boolean;
begin
  // يفحص الريجستري لمعرفة ما إذا كانت حزمة Visual C++ 2015-2022 (x64) مثبتة بالفعل
  Result := RegKeyExists(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64');
end;