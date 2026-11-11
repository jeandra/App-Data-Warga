param(
  [int]$Port = 8765,
  [string]$File = "desain.figcraft"
)

$ErrorActionPreference = "Stop"
$root = $PSScriptRoot
$exe = "C:\Program Files\ArtCraft\FigCraft\figcraft.exe"
$design = Join-Path $root $File

if (-not (Test-Path $exe)) {
  throw "FigCraft tidak ditemukan di $exe"
}
if (-not (Test-Path $design)) {
  throw "File desain tidak ditemukan: $design"
}

$running = Get-Process -Name figcraft -ErrorAction SilentlyContinue
if ($running) {
  $listening = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue
  if ($listening) {
    Write-Host "FigCraft sudah berjalan dan control server aktif di 127.0.0.1:$Port."
    Write-Host "Tidak perlu dijalankan ulang."
    exit 0
  }
  throw "FigCraft sudah berjalan tanpa control server. Tutup jendela FigCraft, lalu jalankan script ini lagi."
}

$arguments = "--control $Port --automation-read-root `"$root`" --automation-write-root `"$root`" `"$design`""
Start-Process -FilePath $exe -ArgumentList $arguments

Write-Host "FigCraft dijalankan:"
Write-Host "  file   : $design"
Write-Host "  control: 127.0.0.1:$Port"
Write-Host "Tunggu jendela FigCraft terbuka, lalu lanjutkan prompt desain di OpenCode."
