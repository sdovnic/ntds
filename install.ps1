Write-Host -Object "-- NEOTOKYO Dedicated Server Installer --"
[string] $Architecture = (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $env:COMPUTERNAME).OSArchitecture
$steamcmd = @{}
$steamcmd['filename'] = 'steamcmd.exe'
$nssm = @{}
$nssm['filename'] = 'nssm.exe'
function menu {
    Write-Host -Object "
1. Remote Installation
2. Local Installation

To exit just press enter.
"
    $selection = Read-Host -Prompt "Select number & press enter"
    switch ($selection) {
        "1" { remote }
        "2" { local }
    }
}
function remote {
    Write-Host -Object ""
    if ($PSVersionTable.PSVersion.Major -lt 3) {
        Write-Warning -Message "Your Client needs a PowerShell Version greater than 2.0 for Remote Installation!"
        Read-Host -Prompt "
Press enter to exit"
        break
    }
    $remotehost = Read-Host -Prompt "Please enter the full qualified domain name of your remote host"
    $credential = Get-Credential -Message $remotehost
    [string] $Architecture = Invoke-Command -ComputerName $remotehost -Credential $credential `
                                            -ScriptBlock {
                                                (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $env:COMPUTERNAME).OSArchitecture
                                            }
    if ($Architecture -notcontains "64-Bit") {
        $nssm['filename'] = 'x86\nssm.exe'
    }
    if (-Not (Test-Path -Path $nssm.filename)) {
        Write-Host -Object "
The File", $nssm.filename, "is missing!
Get the File from http://www.nssm.cc
and place it in the current directory."
        break
    }
    if (-Not (Test-Path -Path $steamcmd.filename)) {
        Write-Host -Object "
The File", $steamcmd.filename, "is missing!
Get the File from https://developer.valvesoftware.com/wiki/SteamCMD
and place it in the current directory."
        break
    }
    Write-Host -Object "
Copying", $nssm.filename, "($Architecture) to", $env:TEMP, "on", $remotehost
    $contents = [IO.File]::ReadAllBytes($nssm.filename)
    $nssm['filename'] = 'nssm.exe'
    Invoke-Command -ComputerName $remotehost -Credential $credential `
                   -ScriptBlock {
                       [IO.File]::WriteAllBytes((Join-Path -Path $env:TEMP -ChildPath $using:nssm.filename), $using:contents)
                   }
    Write-Host -Object "
Copying", $steamcmd.filename, "to", $env:TEMP, "on", $remotehost
    $contents = [IO.File]::ReadAllBytes($steamcmd.filename)
    Invoke-Command -ComputerName $remotehost -Credential $credential `
                   -ScriptBlock {
                       [IO.File]::WriteAllBytes((Join-Path -Path $env:TEMP -ChildPath $using:steamcmd.filename), $using:contents)
                   }
    Write-Host -Object "
Starting remote installation ...
"
    Invoke-Command -ComputerName $remotehost -Credential $credential -FilePath (Join-Path -Path $PSScriptRoot -ChildPath "ntds.ps1")
}
function local {
    Write-Host -Object ""
    if ($Architecture -notcontains "64-Bit") {
        $nssm['filename'] = 'x86\nssm.exe'
    }
    if (-Not (Test-Path -Path $nssm.filename)) {
        Write-Host -Object "
The File", $nssm.filename, "is missing!
Get the File from http://www.nssm.cc
and place it in the current directory."
        break
    }
    if (-Not (Test-Path -Path $steamcmd.filename)) {
        Write-Host -Object "
The File", $steamcmd.filename, "is missing!
Get the File from https://developer.valvesoftware.com/wiki/SteamCMD
and place it in the current directory."
        break
    }
    Write-Host -Object "
Copying", $nssm.filename, "($Architecture) to", $env:TEMP
    Copy-Item -Path $nssm.filename -Destination $env:TEMP
    Write-Host -Object "
Copying", $steamcmd.filename, "to", $env:TEMP
    Copy-Item -Path $steamcmd.filename -Destination $env:TEMP
    Write-Host -Object "
Starting local installation ...
"
    Invoke-Expression -Command "powershell -NoProfile -ExecutionPolicy Bypass .\ntds.ps1"
}
menu
