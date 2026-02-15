param(
  [string]$Url = "http://localhost:6875/login"
)

try {
  $html = (curl.exe -s $Url | Out-String)
} catch {
  Write-Error "Failed to fetch $Url"
  exit 1
}

$hasGithub = [regex]::IsMatch($html, "service/github")
$hasGoogle = [regex]::IsMatch($html, "service/google")

Write-Host "GitHub button: $hasGithub"
Write-Host "Google button: $hasGoogle"
