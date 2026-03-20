param(
  [string]$SourcePath = "C:\Users\jason\brackettrack.html",
  [string]$CommitMessage = "Auto-publish bracket tracker",
  [int]$DebounceSeconds = 3,
  [switch]$RunInitialPublish
)

$ErrorActionPreference = "Stop"

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$publishScript = Join-Path $scriptDir "republish.ps1"

if (-not (Test-Path $publishScript)) {
  throw "Missing publish script: $publishScript"
}

if (-not (Test-Path $SourcePath)) {
  throw "Source file not found: $SourcePath"
}

$watchDir = Split-Path -Parent $SourcePath
$fileName = Split-Path -Leaf $SourcePath

$script:pendingPublish = $false
$script:lastChange = Get-Date

function Invoke-Publish {
  try {
    powershell -ExecutionPolicy Bypass -File $publishScript -SourcePath $SourcePath -CommitMessage $CommitMessage
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Publish completed." -ForegroundColor Green
  } catch {
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] Publish failed: $($_.Exception.Message)" -ForegroundColor Red
  }
}

$watcher = New-Object System.IO.FileSystemWatcher
$watcher.Path = $watchDir
$watcher.Filter = $fileName
$watcher.IncludeSubdirectories = $false
$watcher.NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite, Size, CreationTime'
$watcher.EnableRaisingEvents = $true

$onChange = {
  $script:pendingPublish = $true
  $script:lastChange = Get-Date
}

$ev1 = Register-ObjectEvent -InputObject $watcher -EventName Changed -Action $onChange
$ev2 = Register-ObjectEvent -InputObject $watcher -EventName Created -Action $onChange
$ev3 = Register-ObjectEvent -InputObject $watcher -EventName Renamed -Action $onChange

Write-Host "Watching $SourcePath"
Write-Host "Debounce: $DebounceSeconds seconds"
Write-Host "Press Ctrl+C to stop."

if ($RunInitialPublish) {
  Invoke-Publish
}

try {
  while ($true) {
    Start-Sleep -Milliseconds 750

    if ($script:pendingPublish) {
      $elapsed = (Get-Date) - $script:lastChange
      if ($elapsed.TotalSeconds -ge $DebounceSeconds) {
        $script:pendingPublish = $false
        Invoke-Publish
      }
    }
  }
} finally {
  Unregister-Event -SourceIdentifier $ev1.Name -ErrorAction SilentlyContinue
  Unregister-Event -SourceIdentifier $ev2.Name -ErrorAction SilentlyContinue
  Unregister-Event -SourceIdentifier $ev3.Name -ErrorAction SilentlyContinue
  $watcher.Dispose()
}
