<#
This PowerShell script is an entry point to the Inventory App.
It runs Docker Compose up, regardless of the current working directory (pwd).
#>

$VerbosePreference = 'Continue'

$StdOutPath = '{0}\{1}.log' -f $env:TEMP, ([System.Guid]::NewGuid().Guid)
$StdErrPath = '{0}\{1}.log' -f $env:TEMP, ([System.Guid]::NewGuid().Guid)

$Compose = @{
    FilePath = 'docker-compose'
    ArgumentList = 'up -d --force-recreate --build'
    WorkingDirectory = $PSScriptRoot
    Wait = $true
    RedirectStandardOutput = $StdOutPath
    RedirectStandardError = $StdErrPath
}
Start-Process @Compose

Get-Content -Path $StdOutPath, $StdErrPath

Write-Verbose -Message 'Finished starting application'

docker ps