param(
  [string]$SourcePath = "C:\Users\jason\brackettrack.html",
  [string]$CommitMessage = "Update bracket tracker"
)

$ErrorActionPreference = "Stop"

$repoDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $repoDir

if (-not (Test-Path $SourcePath)) {
  throw "Source file not found: $SourcePath"
}

Copy-Item $SourcePath (Join-Path $repoDir "index.html") -Force

# Stage only the page file so local helper files are not accidentally published.
git add index.html

$hasChangesRaw = & git diff --cached --name-only
$hasChanges = [string]::Join("`n", @($hasChangesRaw))
if ([string]::IsNullOrWhiteSpace($hasChanges)) {
  Write-Output "No site changes detected. Nothing to publish."
  exit 0
}

$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$finalMessage = "$CommitMessage ($timestamp)"

git commit -m $finalMessage | Out-Null
git push origin main | Out-Null

Write-Output "Published successfully to https://jcrutchvt10.github.io/brackettrack-pages/"
