function prompt {
    $ESC = [char]27
    "$ESC[95m$($executionContext.SessionState.Path.CurrentLocation)>$ESC[0m "
}

function search_history {
    $history = Get-Content ~\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt 
    [array]::Reverse($history)
    $arg = $history | fzf
    try {
	    Invoke-Expression $arg 
    } catch {
	    $arg
    }
}

function clean_history {
    $history = Get-Content ~\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt 
    [array]::Reverse($history)
    $history = $history | Select-Object -Unique
    [array]::Reverse($history)
    $history | Out-File ~\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadLine\ConsoleHost_history.txt
}

function folder_sizes{
	invoke-Command { Get-ChildItem -Directory | ForEach-Object { $path = $_.FullName; $size = (Get-ChildItem -Recurse -File -Path $path | Measure-Object -Property Length -Sum).Sum / 1MB; New-Object PSObject -Property @{ Path = $path; SizeMB = $size } } | Format-Table -Property Path,SizeMB -AutoSize }
}

function sed {
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [string[]]$InputObject,
        [Parameter(Mandatory=$true)]
        [string]$pattern,
        [Parameter(Mandatory=$true)]
        [string]$replacement
    )
    process {
        foreach ($line in $InputObject) {
            $line -replace $pattern, $replacement
        }
    }
}

function replace_backslash {
    $args = $args -join ' '
	try {
		& (sed -InputObject $args -pattern "\" -replacement "/")
	} catch {
		sed -InputObject $args -pattern "\" -replacement "/" | Set-Clipboard
	}
}

function mr {
    param(
        [Parameter(Mandatory=$false)]
        [string]$title
    )

    $scriptPath = Resolve-Path "~\.config\powershell\create_mr.py"
    if (Test-Path $scriptPath) {
        python $scriptPath $gitlabUserId $gitlabPrivateToken $gitlabHttpsUrl $gitlabHttpRemote $gitlabSSHRemote $title
    } else {
        Write-Error "Python script not found at path: $scriptPath"
    }
}

function y {
    $tmp = [System.IO.Path]::GetTempFileName()
    yazi $args --cwd-file="$tmp"
    $cwd = Get-Content -Path $tmp
    if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
        Set-Location -LiteralPath $cwd
    }
    Remove-Item -Path $tmp
}
