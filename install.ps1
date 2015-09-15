Write-Host "-- NEOTOKYO Dedicated Server Installer --"
[String] $Architecture = (Get-WmiObject Win32_OperatingSystem -ComputerName $env:COMPUTERNAME).OSArchitecture
$steamcmd = @{}
$steamcmd['filename'] = 'steamcmd.exe'
$nssm = @{}
$nssm['filename'] = 'nssm.exe'
Function menu {
    Write-Host "
1. Remote Installation
2. Local Installation

To exit just press enter.
"
    $selection = Read-Host -Prompt "Select number & press enter"
    Switch ($selection) {
        "1" { remote }
        "2" { local }
    }
}
Function remote {
    If ($PSVersionTable.PSVersion.Major -lt 3) {
        Write-Host "Your Client needs a PowerShell Version greater than 2.0 for Remote Installation!"
        Break
    }
    $remotehost = Read-Host -Prompt "Please enter the full qualified domain name of your remote host"
    $credential = Get-Credential
    Write-Host "
Starting remote installation ...
"
    [String] $Architecture = Invoke-Command -ComputerName $remotehost -Credential $credential `
                                            -ScriptBlock {
                                                (Get-WmiObject Win32_OperatingSystem -ComputerName $env:COMPUTERNAME).OSArchitecture
                                            }
    If ($Architecture -notcontains "64-Bit") {
        $nssm['filename'] = 'x86\nssm.exe'
    }
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
    $contents = [IO.File]::ReadAllBytes($nssm.filename)
    Invoke-Command -ComputerName $remotehost -Credential $credential `
                   -ScriptBlock {
                       [IO.File]::WriteAllBytes((Join-Path -Path $env:TEMP -ChildPath $using:nssm.filename), $using:contents)
                   }
    $contents = [IO.File]::ReadAllBytes($steamcmd.filename)
    Invoke-Command -ComputerName $remotehost -Credential $credential `
                   -ScriptBlock {
                       [IO.File]::WriteAllBytes((Join-Path -Path $env:TEMP -ChildPath $using:steamcmd.filename), $using:contents)
                   }
    Invoke-Command -ComputerName $remotehost -Credential $credential -FilePath ".\ntds.ps1"
}
Function local {
    Write-Host "
Starting local installation ...
"
    If ($Architecture -notcontains "64-Bit") {
        $nssm['filename'] = 'x86\nssm.exe'
    }
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
    Copy-Item -Path $nssm.filename -Destination $env:TEMP
    Copy-Item -Path $steamcmd.filename -Destination $env:TEMP
    Invoke-Expression "powershell -NoProfile -ExecutionPolicy Bypass .\ntds.ps1"
}
menu
