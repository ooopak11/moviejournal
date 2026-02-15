param(
  [string]$BookName = "Movie Journal",
  [string]$HomepagePageName = "Contents",
  [switch]$RemoveEditorExport
)

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Error "docker command not found."
  exit 1
}

$bookNameEscaped = $BookName.Replace("'", "\'")
$homepagePageNameEscaped = $HomepagePageName.Replace("'", "\'")

$code = @'
setting()->put('app-public', true);

$bookName = '__BOOK_NAME__';
$homepagePageName = '__HOMEPAGE_PAGE_NAME__';

$book = \BookStack\Entities\Models\Book::query()->where('name', $bookName)->first();
$homepage = null;
if ($book) {
    $homepage = \BookStack\Entities\Models\Page::query()
        ->where('book_id', $book->id)
        ->whereNull('chapter_id')
        ->where('name', $homepagePageName)
        ->where('draft', false)
        ->first();
}

if ($homepage) {
    $homepageValue = $homepage->id . ':' . $homepage->slug;
    setting()->put('app-homepage-type', 'page');
    setting()->put('app-homepage', $homepageValue);
    echo "Homepage set to page: {$homepageValue}\n";
} else {
    echo "Homepage page not found: {$homepagePageName}\n";
}

$exportPermission = \BookStack\Permissions\Models\RolePermission::query()
    ->where('name', 'content-export')
    ->first();

if ($exportPermission) {
    $roles = ['Public', 'Viewer'];
    if ('__REMOVE_EDITOR_EXPORT__' === 'true') {
        $roles[] = 'Editor';
    }

    foreach ($roles as $roleName) {
        $role = \BookStack\Users\Models\Role::query()
            ->where('display_name', $roleName)
            ->first();

        if (!$role) {
            echo "Role not found: {$roleName}\n";
            continue;
        }

        $attached = $role->permissions()->where('role_permissions.id', $exportPermission->id)->exists();
        if ($attached) {
            $role->permissions()->detach($exportPermission->id);
            echo "Removed content-export from {$roleName}\n";
        } else {
            echo "content-export already removed from {$roleName}\n";
        }
    }
}

echo 'app-public=' . (setting('app-public') ? 'true' : 'false') . "\n";
echo 'app-homepage-type=' . setting('app-homepage-type') . "\n";
echo 'app-homepage=' . setting('app-homepage') . "\n";
'@

$code = $code.Replace('__BOOK_NAME__', $bookNameEscaped)
$code = $code.Replace('__HOMEPAGE_PAGE_NAME__', $homepagePageNameEscaped)
$code = $code.Replace('__REMOVE_EDITOR_EXPORT__', ($RemoveEditorExport.IsPresent ? "true" : "false"))

$code | docker exec -i moviejournal_bookstack php /app/www/artisan tinker

if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to configure public reader mode."
  exit $LASTEXITCODE
}

Write-Host "Public reader mode configured."
