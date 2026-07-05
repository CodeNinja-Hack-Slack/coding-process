#requires -Version 7
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$srcFile = Join-Path $repoRoot "src\flow.md"

if (-not (Test-Path $srcFile)) {
    Write-Error "Source file not found: $srcFile"
    exit 1
}

$sourceContent = Get-Content -LiteralPath $srcFile -Raw -Encoding UTF8

if ([string]::IsNullOrWhiteSpace($sourceContent)) {
    Write-Error "Source file is empty: $srcFile"
    exit 1
}

if ($sourceContent -notmatch '\$ARGUMENTS') {
    Write-Error "Source file must contain `$ARGUMENTS placeholder"
    exit 1
}

$description = "AI 编程 Skill 调度器，根据自然语言描述自动选择并执行 Superpowers skills"

function Write-File {
    param(
        [string]$RelativePath,
        [string]$Content
    )

    $fullPath = Join-Path $repoRoot $RelativePath
    $dir = Split-Path -Parent $fullPath

    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }

    [System.IO.File]::WriteAllText($fullPath, $Content, [System.Text.UTF8Encoding]::new($false))
    Write-Host "  -> $RelativePath"
}

Write-Host "Building platform files from src/flow.md..."

# Claude Code - description frontmatter only
$claudeFrontmatter = "---`ndescription: $description`n---`n`n"
Write-File -RelativePath "claude\.claude\commands\flow.md" -Content ($claudeFrontmatter + $sourceContent)

# OpenCode - description + agent frontmatter
$opencodeFrontmatter = "---`ndescription: $description`nagent: build`n---`n`n"
Write-File -RelativePath "opencode\.opencode\commands\flow.md" -Content ($opencodeFrontmatter + $sourceContent)

# Codex - name + description frontmatter (Skills type)
$skillsFrontmatter = "---`nname: flow`ndescription: ""$description""`n---`n`n"
Write-File -RelativePath "codex\.codex\skills\flow\SKILL.md" -Content ($skillsFrontmatter + $sourceContent)

# Trae - name + description frontmatter (Skills type)
Write-File -RelativePath "trae\.trae\skills\flow\SKILL.md" -Content ($skillsFrontmatter + $sourceContent)

# Trae CN - name + description frontmatter (Skills type)
Write-File -RelativePath "trae-cn\.trae-cn\skills\flow\SKILL.md" -Content ($skillsFrontmatter + $sourceContent)

# OpenCode - opencode.json
$opencodeJson = [ordered]@{
    plugin = @("superpowers@git+https://github.com/obra/superpowers.git#v1.0.0")
    command = [ordered]@{
        flow = [ordered]@{
            description = $description
            template = $sourceContent
        }
    }
} | ConvertTo-Json -Depth 5
Write-File -RelativePath "opencode\opencode.json" -Content $opencodeJson

# Verification
$expectedFiles = @(
    "claude\.claude\commands\flow.md",
    "opencode\.opencode\commands\flow.md",
    "codex\.codex\skills\flow\SKILL.md",
    "trae\.trae\skills\flow\SKILL.md",
    "trae-cn\.trae-cn\skills\flow\SKILL.md",
    "opencode\opencode.json"
)

$allOk = $true
foreach ($file in $expectedFiles) {
    $fullPath = Join-Path $repoRoot $file
    if (-not (Test-Path -LiteralPath $fullPath)) {
        Write-Host "  FAIL: $file not found" -ForegroundColor Red
        $allOk = $false
    } elseif ((Get-Item -LiteralPath $fullPath).Length -eq 0) {
        Write-Host "  FAIL: $file is empty" -ForegroundColor Red
        $allOk = $false
    }
}

if ($allOk) {
    Write-Host "Done! All platform files generated and verified successfully."
} else {
    Write-Error "Some files failed verification."
    exit 1
}
