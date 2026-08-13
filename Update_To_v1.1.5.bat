@echo off
:: Batch Wrapper for Print Tracker App v1.1.5 Updater
title Print Tracker App - Update to v1.1.5
echo ========================================================
echo        Print Tracker App - Automatic Updater v1.1.5
echo ========================================================
echo.

:: Check for Administrator privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [!] Requesting Administrator Privileges...
    powershell -Command "Start-Process '%~0' -Verb RunAs"
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "
$zipUrl = 'https://raw.githubusercontent.com/DPSSCOPY/PrintTrackerApp-Releases/main/PrintTrackerApp_v1.1.5.zip';
$targetDir = 'C:\Program Files\Print Tracker App';
if (-not (Test-Path $targetDir)) { $targetDir = 'C:\Program Files (x86)\Print Tracker App'; }
if (-not (Test-Path $targetDir)) { $targetDir = $PSScriptRoot; }

Write-Host '[1/4] Stopping PrintTrackerApp process if running...' -ForegroundColor Yellow;
Get-Process PrintTrackerApp -ErrorAction SilentlyContinue | Stop-Process -Force;
Start-Sleep -Seconds 1;

Write-Host '[2/4] Downloading Version 1.1.5 package...' -ForegroundColor Yellow;
$tempZip = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), 'PrintTrackerApp_v1.1.5.zip');
$wc = New-Object System.Net.WebClient;
$wc.Headers.Add('User-Agent', 'Mozilla/5.0');
try {
    $wc.DownloadFile($zipUrl, $tempZip);
    Write-Host '    Download completed successfully.' -ForegroundColor Green;
} catch {
    Write-Host '    Download failed:' $_.Exception.Message -ForegroundColor Red;
    Read-Host 'Press Enter to exit';
    exit 1;
}

Write-Host ('[3/4] Updating files in: ' + $targetDir) -ForegroundColor Yellow;
try {
    Expand-Archive -Path $tempZip -DestinationPath $targetDir -Force;
    Remove-Item $tempZip -Force -ErrorAction SilentlyContinue;
    Write-Host '    Files extracted and updated successfully.' -ForegroundColor Green;
} catch {
    Write-Host '    Extraction failed:' $_.Exception.Message -ForegroundColor Red;
    Read-Host 'Press Enter to exit';
    exit 1;
}

Write-Host '[4/4] Setting Spooler permissions and launching App...' -ForegroundColor Yellow;
Start-Process 'icacls' -ArgumentList '\"C:\Windows\System32\spool\PRINTERS\" /grant *S-1-1-0:(OI)(CI)(RX) *S-1-5-32-545:(OI)(CI)(RX) /T' -WindowStyle Hidden -Wait;

$exePath = Join-Path $targetDir 'PrintTrackerApp.exe';
if (Test-Path $exePath) {
    Start-Process -FilePath $exePath;
    Write-Host '========================================================' -ForegroundColor Green;
    Write-Host '        Update to v1.1.5 Complete Successfully!        ' -ForegroundColor Green;
    Write-Host '========================================================' -ForegroundColor Green;
} else {
    Write-Host ('[!] Could not find PrintTrackerApp.exe at ' + $exePath) -ForegroundColor Red;
}
Start-Sleep -Seconds 3;
"

pause
