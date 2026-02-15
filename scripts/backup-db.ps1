param(
  [string]$OutputDir = "backups"
)

if (-not (Test-Path ".env")) {
  Write-Error ".env not found. Run scripts/bootstrap.ps1 first."
  exit 1
}

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Error "docker command not found."
  exit 1
}

$envVars = @{}
Get-Content ".env" | ForEach-Object {
  if ($_ -match "^\s*#") { return }
  if ($_ -notmatch "=") { return }
  $parts = $_.Split("=", 2)
  $envVars[$parts[0].Trim()] = $parts[1].Trim()
}

if (-not (Test-Path $OutputDir)) {
  New-Item -ItemType Directory -Path $OutputDir | Out-Null
}

$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
$outputFile = Join-Path $OutputDir "bookstack-$timestamp.sql"

$dbName = $envVars["DB_DATABASE"]
$dbUser = $envVars["DB_USERNAME"]
$dbPassword = $envVars["DB_PASSWORD"]

if (-not $dbName -or -not $dbUser -or -not $dbPassword) {
  Write-Error "DB settings are missing in .env."
  exit 1
}

docker exec moviejournal_db /usr/bin/mysqldump `
  -u"$dbUser" `
  -p"$dbPassword" `
  "$dbName" > "$outputFile"

if ($LASTEXITCODE -ne 0) {
  Write-Error "Backup failed."
  exit $LASTEXITCODE
}

Write-Host "Backup written to $outputFile"

