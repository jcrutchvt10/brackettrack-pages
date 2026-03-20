# BracketTrack Pages

Static hosting for the NCAA bracket tracker.

## Republish Workflow

Use this command whenever you update the source file at C:/Users/jason/brackettrack.html:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\jason\brackettrack-pages\republish.ps1
```

Optional custom commit text:

```powershell
powershell -ExecutionPolicy Bypass -File C:\Users\jason\brackettrack-pages\republish.ps1 -CommitMessage "Refresh bracket features"
```

Live URL:

https://jcrutchvt10.github.io/brackettrack-pages/
