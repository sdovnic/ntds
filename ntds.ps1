Set-PSDebug -Strict
Write-Host "-- NEOTOKYO Dedicated Server Installer --"
If (-not (Test-Path variable:global:PSSenderInfo)) {
    If ($PSVersionTable.PSVersion.Major -lt 3) {
        [String] $PSScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
    }
    If ($PSVersionTable.PSVersion.Major -lt 3) {
        [String] $PSCommandPath = $MyInvocation.MyCommand.Definition
    }
    If (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Start-Process powershell -WorkingDirectory $PSScriptRoot -Verb runAs `
                                 -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath $args"
        return
    }
}
[String] $Architecture = (Get-WmiObject Win32_OperatingSystem -ComputerName $env:COMPUTERNAME).OSArchitecture
$steamcmd = @{}
$steamcmd['filename'] = 'steamcmd.exe'
If ($Architecture -notcontains "64-Bit") {
    $steamcmd['directory'] = Join-Path -Path ${env:ProgramFiles} -ChildPath 'SteamCMD'
} Else {
    $steamcmd['directory'] = Join-Path -Path ${env:ProgramFiles(x86)} -ChildPath 'SteamCMD'
}
$nssm = @{}
$nssm['filename'] = 'nssm.exe'
$nssm['directory'] = Join-Path -Path ${env:ProgramFiles} -ChildPath 'NSSM'
$nssm['App'] = 'neotokyo'
$nssm['AppDirectory'] = Join-Path -Path $steamcmd.directory -ChildPath '\steamapps\common\NEOTOKYO Dedicated Server'
$nssm['Application'] = Join-Path -Path $nssm.AppDirectory -ChildPath 'srcds.exe'
$nssm['AppParameters'] = '-console -game NeotokyoSource -port 27015 +maxplayers 24 +exec server.cfg +map nt_rise_ctg -allowdebug -dev'
$nssm['DisplayName'] = 'NEOTOKYO Dedicated Server'
$nssm['Description'] = 'NEOTOKYO is a first person shooter that aims to provide a visceral & realistic combat experience in a futuristic setting.'
$nssm['Start'] = 'SERVICE_AUTO_START'
$nssm['ObjectName'] = 'LocalSystem'
$nssm['Type'] = 'SERVICE_WIN32_OWN_PROCESS'
Function menu {
    Write-Host "
1. SteamCMD - Steam Console Client
2. NSSM - the Non-Sucking Service Manager
3. NEOTOKYO Dedicated Server

9. Remove Installation

To exit just press enter.
"
    $selection = Read-Host -Prompt "Select number & press enter"
    If ($selection) {
        Switch ($selection) {
            "1" { steamcmd }
            "2" { nssm }
            "3" { ntds }
            "9" { remove_menu }
        }
    }
}
Function remove_menu {
    Write-Host "
1. Remove SteamCMD - Steam Console Client
2. Remove NSSM - the Non-Sucking Service Manager
3. Remove NEOTOKYO Dedicated Server

To exit just press enter.
"
    $selection = Read-Host -Prompt "Select number & press enter"
    If ($selection) {
        Switch ($selection) {
            "1" { remove_steamcmd }
            "2" { remove_nssm }
            "3" { remove_ntds }
        }
    } Else {
        menu
    }
}
Function remove_steamcmd {
    Write-Host ""
    If (Get-Command -Name Get-NetFirewallRule -ErrorAction SilentlyContinue) {
        If (Get-NetFirewallRule -DisplayName "SteamCMD" -ErrorAction SilentlyContinue) {
            Write-Host "Removing firewall rules for SteamCMD ..."
            Remove-NetFirewallRule -DisplayName "SteamCMD"
        } Else {
            Write-Host "The firewall rules for SteamCMD is not present."
        }
    } Else {
        [String] $Program = (Join-Path -Path $steamcmd.directory -ChildPath $steamcmd.filename)
        [String] $Name = "SteamCMD"
        $ShowRule = netsh advfirewall firewall show rule name="$Name"
        If ($ShowRule -match "$Name") {
            Write-Host "Removing firewall rules for SteamCMD ..."
            Start-Process "netsh" -ArgumentList ("advfirewall", "firewall", "delete", "rule", "name=`"$Name`"") -WindowStyle Hidden -Wait
        } Else {
            Write-Host "The firewall rules for SteamCMD is not present."
        }
    }
    If (Get-Service $nssm.App -ErrorAction SilentlyContinue) {
        Write-Host "Removing the service for", $nssm.DisplayName, "..."
        Set-Service neotokyo -Status Stopped
        $command = Join-Path -Path $nssm.directory -ChildPath $nssm.filename
        Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                      -ArgumentList "remove", $nssm.App, "confirm"
    } Else {
        Write-Host "The service for", $nssm.DisplayName, "is not present."
    }
    If (Get-Command -Name Get-NetFirewallRule -ErrorAction SilentlyContinue) {
        If (Get-NetFirewallRule -DisplayName $nssm.DisplayName -ErrorAction SilentlyContinue) {
            Write-Host "Removing firewall rules for", $nssm.DisplayName, "..."
            Remove-NetFirewallRule -DisplayName $nssm.DisplayName
        } Else {
            Write-Host "The firewall rules for", $nssm.DisplayName, "are not present."
        }
    } Else {
        [String] $Program = $nssm.Application
        [String] $Name = $nssm.DisplayName
        $ShowRule = netsh advfirewall firewall show rule name="$Name"
        If ($ShowRule -match "$Name") {
            Write-Host "Removing firewall rules for", $nssm.DisplayName, "..."
            Start-Process "netsh" -ArgumentList ("advfirewall", "firewall", "delete", "rule", "name=`"$Name`"") -WindowStyle Hidden -Wait
        } Else {
            Write-Host "The firewall rules for", $nssm.DisplayName, "are not present."
        }
    }
    If (Test-Path -Path $steamcmd.directory) {
        Write-Host "Removing", $steamcmd.directory, "..."
        Remove-Item -Path $steamcmd.directory -Recurse -Force
    } Else {
        Write-Host "The directory for", $steamcmd.directory, "is not present."
    }
    remove_menu
}
Function remove_nssm {
    Write-Host ""
    If (Get-Service $nssm.App -ErrorAction SilentlyContinue) {
        Write-Host "Removing the service for", $nssm.DisplayName, "..."
        Set-Service neotokyo -Status Stopped
        $command = Join-Path -Path $nssm.directory -ChildPath $nssm.filename
        Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                      -ArgumentList "remove", $nssm.App, "confirm"
    } Else {
        Write-Host "The service for", $nssm.DisplayName, "is not present."
    }
    If (Test-Path -Path $nssm.directory) {
        Write-Host "Removing", $nssm.directory, "..."
        Remove-Item -Path $nssm.directory -Recurse -Force
    } Else {
        Write-Host "The directory for", $nssm.directory, "is not present."
    }
    remove_menu
}
Function remove_ntds {
    Write-Host ""
    If (Get-Service $nssm.App -ErrorAction SilentlyContinue) {
        Write-Host "Removing the service for", $nssm.DisplayName, "..."
        Set-Service neotokyo -Status Stopped
        $command = Join-Path -Path $nssm.directory -ChildPath $nssm.filename
        Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                      -ArgumentList "remove", $nssm.App, "confirm"
    } Else {
        Write-Host "The service for", $nssm.DisplayName, "is not present."
    }
    If (Get-Command -Name Get-NetFirewallRule -ErrorAction SilentlyContinue) {
        If (Get-NetFirewallRule -DisplayName $nssm.DisplayName -ErrorAction SilentlyContinue) {
            Write-Host "Removing firewall rules for", $nssm.DisplayName, "..."
            Remove-NetFirewallRule -DisplayName $nssm.DisplayName
        } Else {
            Write-Host "The firewall rules for", $nssm.DisplayName, "are not present."
        }
    } Else {
        [String] $Program = $nssm.Application
        [String] $Name = $nssm.DisplayName
        $ShowRule = netsh advfirewall firewall show rule name="$Name"
        If ($ShowRule -match "$Name") {
            Write-Host "Removing firewall rules for", $nssm.DisplayName, "..."
            Start-Process "netsh" -ArgumentList ("advfirewall", "firewall", "delete", "rule", "name=`"$Name`"") -WindowStyle Hidden -Wait
        } Else {
            Write-Host "The firewall rules for", $nssm.DisplayName, "are not present."
        }
    }
    If (Test-Path -Path $nssm.AppDirectory) {
        Write-Host "Removing", $nssm.AppDirectory, "..."
        Remove-Item -Path $nssm.AppDirectory -Recurse -Force
    } Else {
        Write-Host "The directory for", $nssm.AppDirectory, "is not present."
    }
    remove_menu
}
Function nssm {
    Write-Host ""
    If (Test-Path (Join-Path -Path $nssm.directory -ChildPath $nssm.filename)) {
        Write-Host "NSSM already installed."
    } else {
        If (-Not (Test-Path $nssm.directory)) {
            Write-Host "Creating the directory", $nssm.directory, "..."
            New-Item -ItemType Directory -Force -Path $nssm.directory
        }
        If (Test-Path (Join-Path -Path $env:TEMP -ChildPath $nssm.filename)) {
            Write-Host "Installing the file", $nssm.filename, "..."
            Copy-Item -Path (Join-Path -Path $env:TEMP -ChildPath $nssm.filename) -Destination (Join-Path -Path $nssm.directory -ChildPath $nssm.filename)
        } Else {
            Write-Host "Please transfer files first."
        }
    }
    menu
}
Function steamcmd {
    Write-Host ""
    If (Test-Path (Join-Path -Path $steamcmd.directory -ChildPath $steamcmd.filename)) {
        Write-Host "SteamCMD already installed."
    } else {
        If (-Not (Test-Path $steamcmd.directory)) {
            Write-Host "Creating the directory", $steamcmd.directory, "..."
            New-Item -ItemType Directory -Force -Path $steamcmd.directory
        }
        If (Test-Path (Join-Path -Path $env:TEMP -ChildPath $steamcmd.filename)) {
            Write-Host "Installing the file", $steamcmd.filename, "..."
            Copy-Item -Path (Join-Path -Path $env:TEMP -ChildPath $steamcmd.filename) -Destination (Join-Path -Path $steamcmd.directory -ChildPath $steamcmd.filename)
        } Else {
            Write-Host "Please transfer files first."
        }
    }
    If (Get-Command -Name Get-NetFirewallRule -ErrorAction SilentlyContinue) {
        If (Get-NetFirewallRule -DisplayName "SteamCMD" -ErrorAction SilentlyContinue) {
            Write-Host "The firewall rule for SteamCMD is present."
        } Else {
            Write-Host "Adding firewall rule for SteamCMD ..."
            New-NetFirewallRule -DisplayName "SteamCMD" `
                                -Program (Join-Path -Path $steamcmd.directory -ChildPath $steamcmd.filename) `
                                -Direction Outbound -Action Allow
        }
    } Else {
        [String] $Program = (Join-Path -Path $steamcmd.directory -ChildPath $steamcmd.filename)
        [String] $Name = "SteamCMD"
        $ShowRule = netsh advfirewall firewall show rule name="$Name"
        If ($ShowRule -match "$Name") {
            Write-Host "The firewall rule for SteamCMD is present."
        } Else {
            Write-Host "Adding firewall rule for SteamCMD ..."
            Start-Process "netsh" -ArgumentList ("advfirewall", "firewall", "add", "rule", "name=`"$Name`"", "program=`"$Program`"", "dir=out", "action=allow", "profile=any", "enable=yes") -WindowStyle Hidden -Wait
        }
    }
    menu
}
Function ntds {
    Write-Host ""
    If (Test-Path $nssm.Application) {
        Write-Host $nssm.DisplayName ,"already installed."
    } else {
        If (-Not (Test-Path (Join-Path -Path $steamcmd.directory -ChildPath $steamcmd.filename))) {
            Write-Host "You need to install SteamCMD first!"
            menu
        } else {
            Write-Host "Installing", $nssm.DisplayName, "..."
            $command = Join-Path -Path $steamcmd.directory -ChildPath "steamcmd.exe"
            Start-Process -FilePath $command -WorkingDirectory $steamcmd.directory -Wait `
                          -ArgumentList "+login anonymous", "+app_update 313600", "+validate", "+quit"
        }
    }
    If (-Not (Test-Path (Join-Path -Path $nssm.directory -ChildPath $nssm.filename))) {
        Write-Host "You need to install NSSM first!"
        menu
    } else {
        If (-Not (Get-Service $nssm.App -ErrorAction SilentlyContinue)) {
            Write-Host "Installing service for", $nssm.DisplayName, "..."
            $command = Join-Path -Path $nssm.directory -ChildPath $nssm.filename
            Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                          -ArgumentList "install", $nssm.App, $nssm.Application
            Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                          -ArgumentList "set", $nssm.App, "Application", $nssm.Application
            Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                          -ArgumentList "set", $nssm.App, "AppDirectory", $nssm.AppDirectory
            Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                          -ArgumentList "set", $nssm.App, "AppParameters", $nssm.AppParameters
            Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                          -ArgumentList "set", $nssm.App, "DisplayName", $nssm.DisplayName
            Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                          -ArgumentList "set", $nssm.App, "Description", $nssm.Description
            Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                          -ArgumentList "set", $nssm.App, "Start", $nssm.Start
            Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                          -ArgumentList "set", $nssm.App, "ObjectName", $nssm.ObjectName
            Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                          -ArgumentList "set", $nssm.App, "Type", $nssm.Type
        } else {
            Write-Host "The service for", $nssm.DisplayName, "is present."
        }
    }
    If (Get-Command -Name Get-NetFirewallRule -ErrorAction SilentlyContinue) {
        If (-Not (Get-NetFirewallRule -DisplayName $nssm.DisplayName -ErrorAction SilentlyContinue)) {
            Write-Host "Adding firewall rules for", $nssm.DisplayName, "..."
            New-NetFirewallRule -DisplayName $nssm.DisplayName -Program $nssm.Application `
                                -Direction Outbound -Action Allow
            New-NetFirewallRule -DisplayName $nssm.DisplayName -Program $nssm.Application `
                                -Direction Inbound -Action Allow
        } Else {
            Write-Host "The firewall rules for", $nssm.DisplayName, "are present."
        }
    } Else {
        [String] $Program = $nssm.Application
        [String] $Name = $nssm.DisplayName
        $ShowRule = netsh advfirewall firewall show rule name="$Name"
        If ($ShowRule -match "$Name") {
            Write-Host "The firewall rules for", $nssm.DisplayName, "are present."
        } Else {
            Write-Host "Adding firewall rules for", $nssm.DisplayName, "..."
            Start-Process "netsh" -ArgumentList ("advfirewall", "firewall", "add", "rule", "name=`"$Name`"", "program=`"$Program`"", "dir=in", "action=allow", "profile=any", "enable=yes") -WindowStyle Hidden -Wait
            Start-Process "netsh" -ArgumentList ("advfirewall", "firewall", "add", "rule", "name=`"$Name`"", "program=`"$Program`"", "dir=out", "action=allow", "profile=any", "enable=yes") -WindowStyle Hidden -Wait
        }
    }
    menu
}
menu
