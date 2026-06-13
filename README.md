# Codex Neon Terminal Theme Backup

Backup privado do tema de terminal criado localmente.

## Files

- `Microsoft.PowerShell_profile.ps1`: PowerShell profile with the custom prompt, aliases, Git segment, and PSReadLine colors.
- `windows-terminal-settings.json`: Windows Terminal settings with the `Codex Neon` color scheme and profile defaults.
- `restore-theme.ps1`: Restores both files and creates timestamped backups of the current local files first.

## Restore

Run this from PowerShell:

```powershell
powershell.exe -ExecutionPolicy Bypass -File .\restore-theme.ps1
```

Close and reopen Windows Terminal after restoring.
