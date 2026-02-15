param(
  [Parameter(Mandatory = $true)]
  [string]$Email
)

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Error "docker command not found."
  exit 1
}

if (-not (Test-Path ".env")) {
  Write-Error ".env not found."
  exit 1
}

$envMap = @{}
Get-Content ".env" | ForEach-Object {
  if ($_ -notmatch "=") { return }
  $parts = $_.Split("=", 2)
  $envMap[$parts[0].Trim()] = $parts[1].Trim()
}

$dbUser = $envMap["DB_USERNAME"]
$dbPass = $envMap["DB_PASSWORD"]
$dbName = $envMap["DB_DATABASE"]

$safeEmail = $Email.Replace("'", "''")
$sql = "INSERT IGNORE INTO role_user (role_id, user_id) SELECT 1, id FROM users WHERE email = '$safeEmail';"
& docker exec moviejournal_db mariadb "--user=$dbUser" "--password=$dbPass" "--database=$dbName" "--execute=$sql"

if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to promote admin role."
  exit $LASTEXITCODE
}

Write-Host "Admin role ensured for: $Email"
