Set-Alias -Name touch -Value New-Item

Set-Alias -Name rn -Value Rename-Item

Set-Alias -Name vim -Value nvim

Set-Alias -Name v -Value nvim

function fvim {
    nvim $(fzf)
}

function create_env {
    param(
        [Parameter(Mandatory=$true)]
        [string]$name,
        [Parameter(Mandatory=$true)]
        [string]$value
    )
    SETX $name $value
}

function remove_env {
    param(
        [Parameter(Mandatory=$true)]
        [string]$name
    )
    reg delete "HKCU\Environment" /v $name /f
}

function get_env {
    param(
        [Parameter(Mandatory=$true)]
        [string]$name
    )
    $var = [System.Environment]::GetEnvironmentVariable($name)
    echo $var
}

function get_env {
    param(
        [Parameter(Mandatory=$true)]
        [string]$name
    )
    $var = [System.Environment]::GetEnvironmentVariable($name)
    echo $var
}

function get_envs {
    Get-ChildItem Env:
}

function rsp {
    invoke-Command {&"pwsh.exe"} -NoNewScope
}

function rps {
    invoke-Command {&"pwsh.exe"} -NoNewScope
}

Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
