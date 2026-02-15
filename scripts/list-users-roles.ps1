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

$sql = "SELECT u.id, u.name, u.email, COALESCE(GROUP_CONCAT(r.display_name ORDER BY r.id SEPARATOR ','), '') AS roles FROM users u LEFT JOIN role_user ru ON ru.user_id = u.id LEFT JOIN roles r ON r.id = ru.role_id GROUP BY u.id, u.name, u.email ORDER BY u.id;"

& docker exec moviejournal_db mariadb "--user=$dbUser" "--password=$dbPass" "--database=$dbName" "--execute=$sql"

if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to list users/roles."
  exit $LASTEXITCODE
}
