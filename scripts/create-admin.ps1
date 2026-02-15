param(
  [Parameter(Mandatory = $true)]
  [string]$Email,
  [Parameter(Mandatory = $true)]
  [string]$Name,
  [string]$Password,
  [switch]$GeneratePassword,
  [switch]$Initial
)

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Error "docker command not found."
  exit 1
}

if ([string]::IsNullOrWhiteSpace($Password) -and -not $GeneratePassword) {
  Write-Error "Provide -Password or use -GeneratePassword."
  exit 1
}

$args = @(
  "exec",
  "moviejournal_bookstack",
  "php",
  "/app/www/artisan",
  "bookstack:create-admin",
  "--no-interaction",
  "--email=$Email",
  "--name=$Name"
)

if ($GeneratePassword) {
  $args += "--generate-password"
} else {
  $args += "--password=$Password"
}

if ($Initial) {
  $args += "--initial"
}

& docker @args

if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to create/update admin."
  exit $LASTEXITCODE
}

Write-Host "Admin command completed."
