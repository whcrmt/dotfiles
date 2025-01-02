# Requirements

7zip
chafa
fd
fzf
git
jq
lazygit
neovim
openssh
poppler
powershell-core
python
ripgrep
vlc
windows-terminal
yazi
zoxide

# Setup

Clone in ~/.config

Create a symlink for the windows terminal settings using:
`New-Item -ItemType SymbolicLink -Target "~\.config\windows-terminal\settings.json" -Path "~\scoop\apps\windows-terminal\current\settings\settings.json"`

Sensitive variables are stored in ~/.config/powershell/variables.ps1

Include in your $Profile file:
```powershell
get-childitem -path ~\.config\powershell\*.ps1 | foreach-object {
    . $_.FullName
}
```

You might need to bypass execution policy e.g. `"C:\Program Files\PowerShell\7\pwsh.exe" -ExecutionPolicy Bypass -nologo`

Set environment variables:
- YAZI_CONFIG_HOME = ~\.config\yazi\config
- YAZI_FILE_ONE = C:\Program Files\Git\usr\bin\file.exe

