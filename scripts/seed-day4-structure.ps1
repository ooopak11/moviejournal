param(
  [string]$BookName = "Movie Journal",
  [switch]$WithSample
)

if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
  Write-Error "docker command not found."
  exit 1
}

$bookNameEscaped = $BookName.Replace("'", "\'")

$code = @'
auth()->loginUsingId(1);

$bookName = '__BOOK_NAME__';
$bookRepo = app(\BookStack\Entities\Repos\BookRepo::class);
$chapterRepo = app(\BookStack\Entities\Repos\ChapterRepo::class);
$pageRepo = app(\BookStack\Entities\Repos\PageRepo::class);

$book = \BookStack\Entities\Models\Book::query()->where('name', $bookName)->first();
if (!$book) {
    $book = $bookRepo->create([
        'name' => $bookName,
        'description' => 'Jonas Mekas Movie Journal 공동 번역 작업 공간',
    ]);
    echo "Created book: {$book->name}\n";
} else {
    echo "Book exists: {$book->name}\n";
}

$chapterNames = ['1960', '1961', '1962', '1963', '1964'];
$chapters = [];
foreach ($chapterNames as $chapterName) {
    $chapter = \BookStack\Entities\Models\Chapter::query()
        ->where('book_id', $book->id)
        ->where('name', $chapterName)
        ->first();

    if (!$chapter) {
        $chapter = $chapterRepo->create([
            'name' => $chapterName,
            'description' => $chapterName . ' year entries',
        ], $book);
        echo "Created chapter: {$chapter->name}\n";
    }
    $chapters[$chapterName] = $chapter;
}

$createPageIfMissing = function ($parent, string $name, string $markdown) use ($pageRepo) {
    $existingQuery = \BookStack\Entities\Models\Page::query()
        ->where('book_id', $parent instanceof \BookStack\Entities\Models\Book ? $parent->id : $parent->book_id)
        ->where('name', $name)
        ->where('draft', false);

    if ($parent instanceof \BookStack\Entities\Models\Chapter) {
        $existingQuery->where('chapter_id', $parent->id);
    } else {
        $existingQuery->whereNull('chapter_id');
    }

    $existing = $existingQuery->first();
    if ($existing) {
        echo "Page exists: {$name}\n";
        return $existing;
    }

    $draft = $pageRepo->getNewDraftPage($parent);
    $page = $pageRepo->publishDraft($draft, [
        'name' => $name,
        'markdown' => $markdown,
        'summary' => 'Initial IA seed',
    ]);
    echo "Created page: {$name}\n";
    return $page;
};

$indexDate = <<<'MD'
# Index by Date

Browse entries by year.

- 1960
- 1961
- 1962
- 1963
- 1964

Use search query examples:

- `{name:"1960"}`
- `{name:"1960-01"}`
- `{updated_after:2026-01-01}`
MD;

$indexPeople = <<<'MD'
# Index by People

Use one tag format consistently:

- akira-kurosawa
- humphrey-bogart
- jonas-mekas

Search examples:

- `{tag:akira-kurosawa}`
- `{tag:jonas-mekas}`
MD;

$indexPlaces = <<<'MD'
# Index by Places

Suggested tags:

- new-york
- little-carnegie
- tokyo

Search examples:

- `{tag:new-york}`
- `{tag:little-carnegie}`
MD;

$indexTopics = <<<'MD'
# Index by Topics

Suggested tags:

- cinema
- criticism
- exile

Search examples:

- `{tag:cinema}`
- `{tag:criticism}`
MD;

$entryTemplate = <<<'MD'
# Entry Template

Entry Date: YYYY-MM-DD
Period Label:
Source Page:
People:
Places:
Topics:
Translation Status: draft

## Source Text

[Original text]

## Korean Translation

[Translated text]

## Editorial Notes

- terminology decisions
- open translation questions

## Related Entries

- [link to nearby date entries]
MD;

$createPageIfMissing($book, 'Index by Date', $indexDate);
$createPageIfMissing($book, 'Index by People', $indexPeople);
$createPageIfMissing($book, 'Index by Places', $indexPlaces);
$createPageIfMissing($book, 'Index by Topics', $indexTopics);
$createPageIfMissing($book, 'Entry Template', $entryTemplate);
'@

$code = $code.Replace('__BOOK_NAME__', $bookNameEscaped)

if ($WithSample) {
  $code += @'
$sample = <<<'MD'
# 1960-01-13 - On Kurosawa and Drunken Angel

Entry Date: 1960-01-13
Period Label:
Source Page: p. 8
People: akira-kurosawa, humphrey-bogart
Places: little-carnegie
Topics: cinema, criticism
Translation Status: draft

## Source Text

The year begins with Akira Kurosawa's _Drunken Angel_ at the Little Carnegie...

## Korean Translation

[번역문 입력]

## Editorial Notes

- 고유명사 표기 통일 필요
- 초벌 번역 후 검수 예정

## Related Entries

- 1960 section
MD;

$createPageIfMissing($chapters['1960'], '1960-01-13 - On Kurosawa and Drunken Angel', $sample);
'@
}

$code += "echo `"Day 4 structure seed complete.\n`";"

$code | docker exec -i moviejournal_bookstack php /app/www/artisan tinker

if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to seed Day 4 structure."
  exit $LASTEXITCODE
}

Write-Host "Day 4 structure seed complete."
