# Abre el puerto 3777 (API Nest) en el firewall de Windows para la red privada (LAN).
# Ejecutar en PowerShell como Administrador:
#   Set-ExecutionPolicy -Scope Process Bypass -Force; .\scripts\abrir-firewall-api-3777.ps1

$ruleName = "ERP Minera Yungua API 3777"
$existing = netsh advfirewall firewall show rule name="$ruleName" 2>$null
if ($LASTEXITCODE -eq 0) {
    Write-Host "La regla '$ruleName' ya existe."
    exit 0
}

netsh advfirewall firewall add rule name="$ruleName" dir=in action=allow protocol=TCP localport=3777 profile=private
if ($LASTEXITCODE -ne 0) {
    Write-Error "No se pudo crear la regla. Ejecuta este script como Administrador."
    exit 1
}

Write-Host "Regla creada: TCP 3777 entrante (perfil Privado)."
Write-Host "IP de esta PC en LAN (usa en --dart-define=API_BASE):"
Get-NetIPAddress -AddressFamily IPv4 | Where-Object { $_.IPAddress -notlike '127.*' -and $_.PrefixOrigin -ne 'WellKnown' } | ForEach-Object { "  http://$($_.IPAddress):3777/api" }
