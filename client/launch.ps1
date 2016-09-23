### Create Python Virtual Environment and change context into it
$VirtualEnvPath = "$env:USERPROFILE\pyclient"
virtualenv "$VirtualEnvPath"
& $VirtualEnvPath\scripts\activate.ps1 

