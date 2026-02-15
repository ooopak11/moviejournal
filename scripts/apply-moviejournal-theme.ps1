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

if ([string]::IsNullOrWhiteSpace($dbUser) -or [string]::IsNullOrWhiteSpace($dbPass) -or [string]::IsNullOrWhiteSpace($dbName)) {
  Write-Error "DB credentials are missing in .env."
  exit 1
}

$customHeadPath = Join-Path "theme" "moviejournal-custom-head.html"
if (-not (Test-Path $customHeadPath)) {
  Write-Error "$customHeadPath not found."
  exit 1
}

$customHead = Get-Content $customHeadPath -Raw

$settings = @(
  @{ key = "app-name"; value = "Movie Journal"; type = "string" },
  @{ key = "app-name-header"; value = "true"; type = "string" },
  @{ key = "app-color"; value = "#54412f"; type = "string" },
  @{ key = "app-color-dark"; value = "#3f3023"; type = "string" },
  @{ key = "app-color-light"; value = "rgba(84,65,47,0.2)"; type = "string" },
  @{ key = "link-color"; value = "#3b2614"; type = "string" },
  @{ key = "bookshelf-color"; value = "#7a5e45"; type = "string" },
  @{ key = "book-color"; value = "#5e452d"; type = "string" },
  @{ key = "chapter-color"; value = "#72563b"; type = "string" },
  @{ key = "page-color"; value = "#8a6a49"; type = "string" },
  @{ key = "app-custom-head"; value = $customHead; type = "string" }
)

$sqlParts = @()
foreach ($setting in $settings) {
  $k = $setting.key.Replace("'", "''")
  $v = $setting.value.Replace("'", "''")
  $t = $setting.type.Replace("'", "''")
  $sqlParts += "INSERT INTO settings (setting_key, value, type, created_at, updated_at) VALUES ('$k', '$v', '$t', NOW(), NOW()) ON DUPLICATE KEY UPDATE value=VALUES(value), type=VALUES(type), updated_at=NOW();"
}

$sql = ($sqlParts -join " ")
$sql | docker exec -i moviejournal_db mariadb "--user=$dbUser" "--password=$dbPass" "--database=$dbName"

if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to apply theme settings."
  exit $LASTEXITCODE
}

Write-Host "Movie Journal theme applied."
Write-Host "Reload browser to see changes."
