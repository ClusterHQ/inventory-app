<#
This PowerShell script is an entry point to the Inventory App.
It runs Docker Compose up, regardless of the current working directory (pwd).
#>

$Compose = @{
    FilePath = 'docker-compose'
    ArgumentList = 'up -d --force-recreate --build'
    WorkingDirectory = $PSScriptRoot
    Wait = $true
    RedirectStandardOutput = ($StdOutPath = '{0}\{1}.log' -f $env:TEMP, ([System.Guid]::NewGuid().Guid)) 
}
Start-Process @Compose

Get-Content -Path $Compose.RedirectStandardOutput

Write-Host -Object 'Finished starting application'

docker ps