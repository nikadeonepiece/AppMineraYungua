# Tablet conectado por USB: evita el aislamiento AP del router.
# El teléfono usa 127.0.0.1:3777; adb reenvía al backend en esta PC.
#
# Uso (desde flutter_mobile):
#   .\scripts\run-tablet-usb.ps1

$ErrorActionPreference = "Stop"

$adb = Get-Command adb -ErrorAction SilentlyContinue
if (-not $adb) {
    Write-Error "adb no está en PATH. Instala Android platform-tools o abre Android Studio."
}

$devices = adb devices | Select-String "device$" | Where-Object { $_ -notmatch "List of devices" }
if (-not $devices) {
    Write-Error "No hay dispositivo Android conectado por USB con depuración activa."
}

adb reverse tcp:3777 tcp:3777
if ($LASTEXITCODE -ne 0) {
    Write-Error "adb reverse falló."
}

Write-Host "adb reverse activo: teléfono 127.0.0.1:3777 -> PC :3777"
Write-Host "Iniciando Flutter..."
Write-Host ""

flutter run `
  --dart-define=API_BASE=http://127.0.0.1:3777/api `
  --dart-define=DEVICE_ID=tablet-01 `
  --dart-define=REPLAY_SECRET=offline-replay-secret-dev `
  @args
