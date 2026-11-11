@echo off
setlocal
chcp 65001 >nul
title SIP-Warga + FigCraft

cd /d "%~dp0"

echo ============================================
echo   SIP-Warga + FigCraft
echo ============================================
echo.

rem 1. Siapkan FigCraft dengan control server + izin folder proyek.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0buka-figcraft.ps1"
if errorlevel 1 (
  echo.
  echo [ERROR] FigCraft gagal disiapkan. Baca pesan di atas.
  echo         Jika FigCraft sedang terbuka, tutup dulu jendelanya.
  echo.
  pause
  exit /b 1
)

rem Mode uji: hentikan sebelum membuka OpenCode.
if /I "%~1"=="--figcraft-only" (
  echo.
  echo [OK] Mode uji selesai. FigCraft siap dipakai.
  exit /b 0
)

rem 2. Tunggu control server benar-benar siap (maksimal 30 detik).
echo.
echo Menunggu control server FigCraft di port 8765 ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$end=(Get-Date).AddSeconds(30); while((Get-Date) -lt $end){ if(Get-NetTCPConnection -LocalPort 8765 -State Listen -ErrorAction SilentlyContinue){ exit 0 }; Start-Sleep -Milliseconds 500 }; exit 1"
if errorlevel 1 (
  echo.
  echo [PERINGATAN] Control server belum siap setelah 30 detik.
  echo              OpenCode tetap dibuka. Jika koneksi MCP gagal,
  echo              jalankan /reload atau sambungkan lewat /mcps.
  timeout /t 4 >nul
) else (
  echo [OK] Control server aktif di 127.0.0.1:8765
)

rem 3. Buka OpenCode di folder proyek ini.
where opencode >nul 2>nul
if errorlevel 1 (
  echo.
  echo [ERROR] Perintah "opencode" tidak ditemukan di PATH.
  echo         Install OpenCode atau jalankan dari terminal yang benar.
  pause
  exit /b 1
)

echo.
echo Membuka OpenCode ...
echo Silakan prompt desain atau "terapkan desain FigCraft ke aplikasi".
echo.
opencode

echo.
echo OpenCode ditutup. FigCraft tetap berjalan.
pause
endlocal
