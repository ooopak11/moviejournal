param(
  [string]$RoleName = "Editor",
  [switch]$DisableRegistration
)

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Error "docker command not found."
  exit 1
}

$escapedRole = $RoleName.Replace("'", "''")
$roleId = docker exec moviejournal_bookstack php /app/www/artisan tinker --execute="echo Illuminate\Support\Facades\DB::table('roles')->where('display_name','$escapedRole')->value('id') ?? '';"

if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to read roles."
  exit $LASTEXITCODE
}

$roleId = ($roleId | Out-String).Trim()
if ([string]::IsNullOrWhiteSpace($roleId)) {
  Write-Error "Role '$RoleName' not found."
  exit 1
}

if ($DisableRegistration) {
  docker exec moviejournal_bookstack php /app/www/artisan tinker --execute="setting()->put('registration-enabled','false'); echo 'registration-enabled=' . (setting('registration-enabled') ? 'true' : 'false');"
  exit $LASTEXITCODE
}

docker exec moviejournal_bookstack php /app/www/artisan tinker --execute="setting()->put('registration-enabled','true'); setting()->put('registration-role',$roleId); echo 'registration-enabled=' . (setting('registration-enabled') ? 'true' : 'false') . ' registration-role=' . setting('registration-role');"

if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to apply registration settings."
  exit $LASTEXITCODE
}

Write-Host "Registration defaults updated: role=$RoleName (id=$roleId)"

