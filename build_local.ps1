Write-Host ">>> [1/4] Generating code for Drift and Envied..." -ForegroundColor Yellow
Set-Location packages/local_storage_api
flutter pub get
dart run build_runner build --delete-conflicting-outputs
Set-Location ../..
flutter pub get
dart run build_runner build --delete-conflicting-outputs

Write-Host ">>> [2/4] Compiling Flutter Windows Release..." -ForegroundColor Yellow
flutter build windows --release -t lib/main_production.dart

Write-Host ">>> [3/4] Ensuring sqlite3.dll is in Release folder..." -ForegroundColor Yellow
$targetDir = "build\windows\x64\runner\Release"
if (Test-Path "Redist\sqlite3.dll") {
    Copy-Item "Redist\sqlite3.dll" -Destination "$targetDir\sqlite3.dll" -Force
}

Write-Host ">>> [4/4] Compiling Inno Setup Installer..." -ForegroundColor Yellow
$iscc = "C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
if (Test-Path $iscc) {
    & $iscc /DMyAppVersion=test-local sakanos_setup.iss
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nSUCCESS: Local build complete! Test installer created in Output/" -ForegroundColor Green
    } else {
        Write-Host "`nERROR: Inno Setup compilation failed with exit code $LASTEXITCODE" -ForegroundColor Red
    }
} else {
    Write-Host "`nERROR: Inno Setup compiler not found at $iscc" -ForegroundColor Red
}