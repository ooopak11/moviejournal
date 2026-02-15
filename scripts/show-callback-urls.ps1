if (-not (Test-Path ".env")) {
  Write-Error ".env not found."
  exit 1
}

$appUrlLine = Get-Content ".env" | Where-Object { $_ -like "APP_URL=*" } | Select-Object -First 1
if (-not $appUrlLine) {
  Write-Error "APP_URL not found in .env."
  exit 1
}

$appUrl = $appUrlLine.Split("=", 2)[1].TrimEnd("/")
if ([string]::IsNullOrWhiteSpace($appUrl)) {
  Write-Error "APP_URL is empty."
  exit 1
}

Write-Host "GitHub callback:"
Write-Host "$appUrl/login/service/github/callback"
Write-Host ""
Write-Host "Google callback:"
Write-Host "$appUrl/login/service/google/callback"

