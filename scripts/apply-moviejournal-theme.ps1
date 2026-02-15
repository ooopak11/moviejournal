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

$customHead = @'
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:wght@400;500;600;700&family=Noto+Serif+KR:wght@400;500;700&display=swap" rel="stylesheet">
<style id="moviejournal-theme">
:root {
  --mj-paper: #c3b392;
  --mj-paper-soft: #cec0a4;
  --mj-ink: #1d1712;
  --mj-ink-soft: #3a2f25;
  --mj-border: #8f7f64;
}

body,
html {
  background: var(--mj-paper) !important;
  color: var(--mj-ink) !important;
}

body {
  font-family: "Cormorant Garamond", "Noto Serif KR", serif !important;
  letter-spacing: 0.01em;
}

#app {
  background:
    radial-gradient(circle at 8% 15%, rgba(255,255,255,0.09) 0 1px, transparent 2px) 0 0/26px 24px,
    radial-gradient(circle at 80% 70%, rgba(95,72,45,0.08) 0 1px, transparent 2px) 0 0/34px 30px,
    linear-gradient(180deg, var(--mj-paper-soft), var(--mj-paper));
}

.tri-layout-container,
.container {
  max-width: 1280px;
}

.primary-background,
.card,
.entity-list-item,
.grid-card,
.entity-meta,
.tag-item,
.dropdown-menu,
.slim-scroll {
  background-color: rgba(236, 224, 198, 0.8) !important;
  border-color: rgba(143, 127, 100, 0.45) !important;
}

.content-wrap,
.page-content,
.page-content p,
.page-content li,
.page-content td,
.page-content blockquote {
  color: var(--mj-ink) !important;
  font-size: 1.12rem;
  line-height: 1.72;
}

.page-content h1,
.page-content h2,
.page-content h3,
.entity-title,
.entity-list-item-name {
  font-family: "Cormorant Garamond", "Noto Serif KR", serif !important;
  letter-spacing: 0.02em;
  color: #15100d !important;
}

.page-content h1 {
  font-size: 3rem;
  text-transform: uppercase;
  letter-spacing: 0.08em;
}

.page-content h2 {
  font-size: 1.55rem;
  margin-top: 1.8rem;
}

.page-content hr {
  border-color: rgba(58, 47, 37, 0.3);
}

.page-content code,
.page-content pre {
  background: rgba(70, 48, 31, 0.1) !important;
  border-color: rgba(70, 48, 31, 0.15) !important;
  color: #241a13 !important;
}

.header,
.header-search-box,
.search-box,
.page-editor-toolbar,
.entity-meta {
  border-color: rgba(58, 47, 37, 0.28) !important;
}

a,
.link,
.entity-meta a {
  color: #3b2614 !important;
}

.button,
.button.outline {
  border-color: #4d3928 !important;
  color: #2a1d13 !important;
  background: rgba(236, 224, 198, 0.65) !important;
}

.button:hover {
  background: rgba(212, 196, 163, 0.82) !important;
}

/* Entry reading surface */
.page-content {
  background:
    radial-gradient(circle at 20% 10%, rgba(255,255,255,0.08) 0 1px, transparent 2px) 0 0/24px 22px,
    linear-gradient(180deg, rgba(229,216,188,0.95), rgba(218,202,170,0.96));
  border: 1px solid rgba(96, 73, 48, 0.24);
  box-shadow: 0 10px 28px rgba(37, 22, 8, 0.14);
  padding: 2.4rem 3rem;
}

@media (max-width: 900px) {
  .page-content {
    padding: 1.2rem 1rem;
  }
  .page-content h1 {
    font-size: 2rem;
  }
}
</style>
'@

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
