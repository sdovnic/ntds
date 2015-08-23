Write-Host "-- NEOTOKYO Dedicated Server Installer --"
$steamcmd = @{}
$steamcmd['filename'] = 'steamcmd.exe'
$nssm = @{}
$nssm['filename'] = 'nssm.exe'
If (-Not (Test-Path $nssm.filename)) {
    Write-Host "
The File", $nssm.filename, "is missing!
Get the File from http://www.nssm.cc
and place it in the current directory."
    Break
}
If (-Not (Test-Path $steamcmd.filename)) {
    Write-Host "
The File", $steamcmd.filename, "is missing!
Get the File from https://developer.valvesoftware.com/wiki/SteamCMD
and place it in the current directory."
    Break
}
Function menu {
    Write-Host "
1. Remote Installation
2. Local Installation
"
    $selection = Read-Host -Prompt "Select number & press enter"
    Switch ($selection) {
        "1" { remote }
        "2" { local }
    }
}
Function remote {
    Write-Host ""
    $remotehost = Read-Host -Prompt "Please enter the full qualified domain name of your remote host"
    $credential = Get-Credential
    Write-Host "
Starting remote installation ...
"
    $contents = [IO.File]::ReadAllBytes($steamcmd.filename)
    Invoke-Command -ComputerName $remotehost `
                  -Credential $credential `
                  -ScriptBlock {
                      [IO.File]::WriteAllBytes((Join-Path -Path $env:TEMP -ChildPath $using:steamcmd.filename), $using:contents)
                  }
    $contents = [IO.File]::ReadAllBytes($nssm.filename)
    Invoke-Command -ComputerName $remotehost `
                   -Credential $credential `
                   -ScriptBlock {
                       [IO.File]::WriteAllBytes((Join-Path -Path $env:TEMP -ChildPath $using:nssm.filename), $using:contents)
                   }
    Invoke-Command -ComputerName $remotehost `
                   -Credential $credential `
                   -FilePath ".\ntds.ps1"
    menu
}
Function local {
    Write-Host "
Starting local installation ...
"
    Copy-Item -Path $steamcmd.filename -Destination $env:TEMP
    Copy-Item -Path $nssm.filename -Destination $env:TEMP
    Invoke-Expression "powershell -NoProfile -ExecutionPolicy Bypass .\ntds.ps1"
    menu
}
menu
