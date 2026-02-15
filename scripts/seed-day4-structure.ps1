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
        'description' => 'Jonas Mekas Movie Journal 공동 번역 작업 공간 (1959~1968)',
    ]);
    echo "Created book: {$book->name}\n";
} else {
    echo "Book exists: {$book->name}\n";
}

$chapterNames = array_map(static fn ($y) => (string) $y, range(1959, 1968));
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

$priority = 1;
foreach ($chapterNames as $chapterName) {
    $chapter = $chapters[$chapterName];
    if ((int) $chapter->priority !== $priority) {
        $chapter->priority = $priority;
        $chapter->save();
    }
    $priority++;
}

$upsertPage = function (
    $parent,
    string $name,
    string $markdown,
    string $summary = 'Initial IA seed',
    bool $updateExisting = false
) use ($pageRepo) {
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
        if (!$updateExisting) {
            echo "Page exists: {$name}\n";
            return $existing;
        }

        $page = $pageRepo->update($existing, [
            'name' => $name,
            'markdown' => $markdown,
            'summary' => $summary,
        ]);
        echo "Updated page: {$name}\n";
        return $page;
    }

    $draft = $pageRepo->getNewDraftPage($parent);
    $page = $pageRepo->publishDraft($draft, [
        'name' => $name,
        'markdown' => $markdown,
        'summary' => $summary,
    ]);
    echo "Created page: {$name}\n";
    return $page;
};

$introduction = <<<'MD'
# Introduction

이 사이트는 Jonas Mekas의 *Movie Journal* 기록(1959~1968)을 한국어로 공동 번역/편집하기 위한 작업 공간입니다.

읽기 화면에서는 책처럼 보이도록 구성되어 있으며, 편집 권한이 있는 사용자만 편집 보조 섹션을 볼 수 있습니다.

## 이용 원칙

- 원문은 저작권 이슈를 고려하여 공개 화면에서 표시하지 않습니다.
- 기본 열람자는 제목과 한국어 번역문 중심으로 읽습니다.
- `Editorial Notes`, `Related Entries`, `Source Text`는 편집 시에만 활용합니다.
MD;

$entryTemplate = <<<'MD'
# Entry Template

Entry Date: YYYY-MM-DD
Year: YYYY
Source Page:
People:
Places:
Topics:
Translation Status: draft

## Korean Text

[한국어 번역문 입력]

## Editorial Notes

- 용어 통일
- 해석 이견
- 추가 확인 사항

## Related Entries

- [연결할 엔트리 링크]

## Source Text

[편집용 원문 보관 영역]
MD;

$introductionPage = $upsertPage($book, 'Introduction', $introduction);
$upsertPage($book, 'Entry Template', $entryTemplate);

$tocRows = [
    ['label' => 'Introduction', 'url' => '/books/' . $book->slug . '/page/' . $introductionPage->slug, 'page' => 'page vii'],
    ['label' => '1959', 'url' => '/books/' . $book->slug . '/chapter/' . $chapters['1959']->slug, 'page' => 'page i'],
    ['label' => '1960', 'url' => '/books/' . $book->slug . '/chapter/' . $chapters['1960']->slug, 'page' => 'page 9'],
    ['label' => '1961', 'url' => '/books/' . $book->slug . '/chapter/' . $chapters['1961']->slug, 'page' => 'page 22'],
    ['label' => '1962', 'url' => '/books/' . $book->slug . '/chapter/' . $chapters['1962']->slug, 'page' => 'page 46'],
    ['label' => '1963', 'url' => '/books/' . $book->slug . '/chapter/' . $chapters['1963']->slug, 'page' => 'page 77'],
    ['label' => '1964', 'url' => '/books/' . $book->slug . '/chapter/' . $chapters['1964']->slug, 'page' => 'page 111'],
    ['label' => '1965', 'url' => '/books/' . $book->slug . '/chapter/' . $chapters['1965']->slug, 'page' => 'page 173'],
    ['label' => '1966', 'url' => '/books/' . $book->slug . '/chapter/' . $chapters['1966']->slug, 'page' => 'page 222'],
    ['label' => '1967', 'url' => '/books/' . $book->slug . '/chapter/' . $chapters['1967']->slug, 'page' => 'page 264'],
    ['label' => '1968', 'url' => '/books/' . $book->slug . '/chapter/' . $chapters['1968']->slug, 'page' => 'page 303'],
];

$contents = "# Contents\n\n";
$contents .= "<div class=\"mj-book-contents\">\n";
$contents .= "  <div class=\"mj-book-contents-label\">CONTENTS</div>\n";
$contents .= "  <div class=\"mj-book-contents-list\">\n";
foreach ($tocRows as $row) {
    $contents .= "    <div class=\"mj-book-contents-row\"><a href=\"{$row['url']}\">{$row['label']}</a><span>{$row['page']}</span></div>\n";
}
$contents .= "  </div>\n";
$contents .= "</div>\n";

$upsertPage($book, 'Contents', $contents, 'Generated table of contents', true);
'@

$code = $code.Replace('__BOOK_NAME__', $bookNameEscaped)

if ($WithSample) {
  $code += @'
$sample = <<<'MD'
# 1960-01-13 - On Kurosawa and Drunken Angel

Entry Date: 1960-01-13
Year: 1960
Source Page: p. 8
People: akira-kurosawa, humphrey-bogart
Places: little-carnegie
Topics: cinema, criticism
Translation Status: draft

## Korean Text

[번역문 입력]

## Editorial Notes

- 고유명사 표기 통일 필요
- 초벌 번역 후 검수 예정

## Related Entries

- 1960 section

## Source Text

[편집용 원문 입력]
MD;

$upsertPage($chapters['1960'], '1960-01-13 - On Kurosawa and Drunken Angel', $sample, 'Sample entry seed');
'@
}

$code += "echo `"Day 4 structure seed complete.\n`";"

$code | docker exec -i moviejournal_bookstack php /app/www/artisan tinker

if ($LASTEXITCODE -ne 0) {
  Write-Error "Failed to seed Day 4 structure."
  exit $LASTEXITCODE
}

Write-Host "Day 4 structure seed complete."
