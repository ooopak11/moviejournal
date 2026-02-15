param(
  [string]$GithubAppId,
  [string]$GithubAppSecret,
  [string]$GoogleAppId,
  [string]$GoogleAppSecret
)

if (-not (Test-Path ".env")) {
  Write-Error ".env not found."
  exit 1
}

$content = Get-Content ".env" -Raw

if (-not [string]::IsNullOrWhiteSpace($GithubAppId)) {
  $content = [regex]::Replace($content, "(?m)^GITHUB_APP_ID=.*$", "GITHUB_APP_ID=$GithubAppId")
}
if (-not [string]::IsNullOrWhiteSpace($GithubAppSecret)) {
  $content = [regex]::Replace($content, "(?m)^GITHUB_APP_SECRET=.*$", "GITHUB_APP_SECRET=$GithubAppSecret")
}
if (-not [string]::IsNullOrWhiteSpace($GoogleAppId)) {
  $content = [regex]::Replace($content, "(?m)^GOOGLE_APP_ID=.*$", "GOOGLE_APP_ID=$GoogleAppId")
}
if (-not [string]::IsNullOrWhiteSpace($GoogleAppSecret)) {
  $content = [regex]::Replace($content, "(?m)^GOOGLE_APP_SECRET=.*$", "GOOGLE_APP_SECRET=$GoogleAppSecret")
}

Set-Content ".env" $content
Write-Host ".env OAuth values updated."
Write-Host "Run: docker compose up -d --force-recreate"

