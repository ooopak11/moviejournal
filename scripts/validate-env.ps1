$baseRequired = @(
  "TZ",
  "BOOKSTACK_PORT",
  "APP_URL",
  "APP_KEY",
  "DB_ROOT_PASSWORD",
  "DB_DATABASE",
  "DB_HOST",
  "DB_PORT",
  "DB_USERNAME",
  "DB_PASSWORD",
  "GITHUB_AUTO_REGISTER",
  "GOOGLE_AUTO_REGISTER"
)

if (-not (Test-Path ".env")) {
  Write-Error ".env not found."
  exit 1
}

$envVars = @{}
Get-Content ".env" | ForEach-Object {
  if ($_ -match "^\s*#") { return }
  if ($_ -notmatch "=") { return }
  $parts = $_.Split("=", 2)
  $envVars[$parts[0].Trim()] = $parts[1].Trim()
}

$missing = @()
foreach ($key in $baseRequired) {
  if (-not $envVars.ContainsKey($key) -or [string]::IsNullOrWhiteSpace($envVars[$key])) {
    $missing += $key
  }
}

$socialPairMissing = @()
if ($envVars.ContainsKey("GITHUB_APP_ID") -or $envVars.ContainsKey("GITHUB_APP_SECRET")) {
  $githubId = $envVars["GITHUB_APP_ID"]
  $githubSecret = $envVars["GITHUB_APP_SECRET"]
  $hasGithubId = -not [string]::IsNullOrWhiteSpace($githubId)
  $hasGithubSecret = -not [string]::IsNullOrWhiteSpace($githubSecret)
  if ($hasGithubId -xor $hasGithubSecret) {
    $socialPairMissing += "GITHUB_APP_ID/GITHUB_APP_SECRET"
  }
}

if ($envVars.ContainsKey("GOOGLE_APP_ID") -or $envVars.ContainsKey("GOOGLE_APP_SECRET")) {
  $googleId = $envVars["GOOGLE_APP_ID"]
  $googleSecret = $envVars["GOOGLE_APP_SECRET"]
  $hasGoogleId = -not [string]::IsNullOrWhiteSpace($googleId)
  $hasGoogleSecret = -not [string]::IsNullOrWhiteSpace($googleSecret)
  if ($hasGoogleId -xor $hasGoogleSecret) {
    $socialPairMissing += "GOOGLE_APP_ID/GOOGLE_APP_SECRET"
  }
}

$placeholders = @()
foreach ($key in $baseRequired + @("GITHUB_APP_ID", "GITHUB_APP_SECRET", "GOOGLE_APP_ID", "GOOGLE_APP_SECRET")) {
  if ($envVars.ContainsKey($key) -and $envVars[$key] -match "replace_with_") {
    $placeholders += $key
  }
}

if ($missing.Count -gt 0) {
  Write-Host "Missing keys:"
  $missing | ForEach-Object { Write-Host " - $_" }
  exit 1
}

if ($socialPairMissing.Count -gt 0) {
  Write-Host "Social login pair mismatch:"
  $socialPairMissing | ForEach-Object { Write-Host " - $_" }
  exit 1
}

if ($placeholders.Count -gt 0) {
  Write-Host "Placeholder values still present:"
  $placeholders | ForEach-Object { Write-Host " - $_" }
  exit 1
}

Write-Host ".env validation passed."
