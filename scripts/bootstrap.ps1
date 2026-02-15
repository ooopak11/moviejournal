param(
  [string]$EnvFile = ".env",
  [switch]$Force
)

if ((Test-Path $EnvFile) -and -not $Force) {
  Write-Host "$EnvFile already exists. Skipping generation."
  exit 0
}

if (-not (Test-Path ".env.example")) {
  Write-Error ".env.example not found."
  exit 1
}

function New-HexSecret([int]$ByteLength = 24) {
  $bytes = [byte[]]::new($ByteLength)
  [Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
  return (-join ($bytes | ForEach-Object { $_.ToString("x2") }))
}

$randomBytes = [byte[]]::new(32)
[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($randomBytes)
$appKey = "base64:" + [Convert]::ToBase64String($randomBytes)
$dbRootPassword = New-HexSecret
$dbPassword = New-HexSecret

(Get-Content ".env.example") `
  -replace "APP_KEY=base64:replace_with_generated_key", "APP_KEY=$appKey" `
  -replace "DB_ROOT_PASSWORD=replace_with_strong_root_password", "DB_ROOT_PASSWORD=$dbRootPassword" `
  -replace "DB_PASSWORD=replace_with_strong_db_password", "DB_PASSWORD=$dbPassword" `
  | Set-Content $EnvFile

Write-Host "$EnvFile created."
Write-Host "Next: update OAuth credentials in $EnvFile if social login is needed."
