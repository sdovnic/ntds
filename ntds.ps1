Write-Host -Object "-- NEOTOKYO Dedicated Server Installer --"
if (-not (Test-Path -Path variable:global:PSSenderInfo)) {
    if ($PSVersionTable.PSVersion.Major -lt 3) {
        [string] $PSScriptRoot = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
    }
    if ($PSVersionTable.PSVersion.Major -lt 3) {
        [string] $PSCommandPath = $MyInvocation.MyCommand.Definition
    }
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Start-Process -FilePath "powershell" -WorkingDirectory $PSScriptRoot -Verb runAs `
                      -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $PSCommandPath $args"
        return
    }
}
[string] $Architecture = (Get-WmiObject -Class Win32_OperatingSystem -ComputerName $env:COMPUTERNAME).OSArchitecture
$steamcmd = @{}
$steamcmd['filename'] = 'steamcmd.exe'
if ($Architecture -notcontains "64-Bit") {
    $steamcmd['directory'] = Join-Path -Path ${env:ProgramFiles} -ChildPath 'SteamCMD'
} else {
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
    Write-Host -Object "
1. SteamCMD - Steam Console Client
2. NSSM - the Non-Sucking Service Manager
3. NEOTOKYO Dedicated Server

9. Remove Installation

To exit just press enter.
"
    $selection = Read-Host -Prompt "Select number & press enter"
    if ($selection) {
        switch ($selection) {
            "1" { steamcmd }
            "2" { nssm }
            "3" { ntds }
            "9" { remove_menu }
        }
    }
}
Function remove_menu {
    Write-Host -Object "
1. Remove SteamCMD - Steam Console Client
2. Remove NSSM - the Non-Sucking Service Manager
3. Remove NEOTOKYO Dedicated Server

To exit just press enter.
"
    $selection = Read-Host -Prompt "Select number & press enter"
    if ($selection) {
        switch ($selection) {
            "1" { remove_steamcmd }
            "2" { remove_nssm }
            "3" { remove_ntds }
        }
    } else {
        menu
    }
}
Function remove_steamcmd {
    Write-Host -Object ""
    if (Get-Command -Name Get-NetFirewallRule -ErrorAction SilentlyContinue) {
        if (Get-NetFirewallRule -DisplayName "SteamCMD" -ErrorAction SilentlyContinue) {
            Write-Host -Object "Removing firewall rules for SteamCMD ..."
            Remove-NetFirewallRule -DisplayName "SteamCMD"
        } else {
            Write-Host -Object "The firewall rules for SteamCMD is not present."
        }
    } else {
        [string] $Program = (Join-Path -Path $steamcmd.directory -ChildPath $steamcmd.filename)
        [string] $Name = "SteamCMD"
        $ShowRule = netsh advfirewall firewall show rule name="$Name"
        if ($ShowRule -match "$Name") {
            Write-Host -Object "Removing firewall rules for SteamCMD ..."
            Start-Process -FilePath "netsh" -ArgumentList ("advfirewall", "firewall", "delete", "rule", "name=`"$Name`"") -WindowStyle Hidden -Wait
        } else {
            Write-Host -Object "The firewall rules for SteamCMD is not present."
        }
    }
    if (Get-Service -Name $nssm.App -ErrorAction SilentlyContinue) {
        Write-Host -Object "Removing the service for", $nssm.DisplayName, "..."
        Set-Service -Name $nssm.App -Status Stopped
        $command = Join-Path -Path $nssm.directory -ChildPath $nssm.filename
        Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                      -ArgumentList "remove", $nssm.App, "confirm"
    } else {
        Write-Host -Object "The service for", $nssm.DisplayName, "is not present."
    }
    if (Get-Command -Name Get-NetFirewallRule -ErrorAction SilentlyContinue) {
        if (Get-NetFirewallRule -DisplayName $nssm.DisplayName -ErrorAction SilentlyContinue) {
            Write-Host -Object "Removing firewall rules for", $nssm.DisplayName, "..."
            Remove-NetFirewallRule -DisplayName $nssm.DisplayName
        } else {
            Write-Host -Object "The firewall rules for", $nssm.DisplayName, "are not present."
        }
    } else {
        [string] $Program = $nssm.Application
        [string] $Name = $nssm.DisplayName
        $ShowRule = netsh advfirewall firewall show rule name="$Name"
        if ($ShowRule -match "$Name") {
            Write-Host -Object "Removing firewall rules for", $nssm.DisplayName, "..."
            Start-Process -FilePath "netsh" -ArgumentList ("advfirewall", "firewall", "delete", "rule", "name=`"$Name`"") -WindowStyle Hidden -Wait
        } else {
            Write-Host -Object "The firewall rules for", $nssm.DisplayName, "are not present."
        }
    }
    if (Test-Path -Path $steamcmd.directory) {
        Write-Host -Object "Removing", $steamcmd.directory, "..."
        Remove-Item -Path $steamcmd.directory -Recurse -Force
    } else {
        Write-Host -Object "The directory for", $steamcmd.directory, "is not present."
    }
    remove_menu
}
Function remove_nssm {
    Write-Host -Object ""
    if (Get-Service -Name $nssm.App -ErrorAction SilentlyContinue) {
        Write-Host -Object "Removing the service for", $nssm.DisplayName, "..."
        Set-Service -Name $nssm.App -Status Stopped
        $command = Join-Path -Path $nssm.directory -ChildPath $nssm.filename
        Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                      -ArgumentList "remove", $nssm.App, "confirm"
    } else {
        Write-Host -Object "The service for", $nssm.DisplayName, "is not present."
    }
    if (Test-Path -Path $nssm.directory) {
        Write-Host -Object "Removing", $nssm.directory, "..."
        Remove-Item -Path $nssm.directory -Recurse -Force
    } else {
        Write-Host -Object "The directory for", $nssm.directory, "is not present."
    }
    remove_menu
}
Function remove_ntds {
    Write-Host -Object ""
    if (Get-Service -Name $nssm.App -ErrorAction SilentlyContinue) {
        Write-Host -Object "Removing the service for", $nssm.DisplayName, "..."
        Set-Service -Name $nssm.App -Status Stopped
        $command = Join-Path -Path $nssm.directory -ChildPath $nssm.filename
        Start-Process -FilePath $command -WorkingDirectory $nssm.directory -Wait `
                      -ArgumentList "remove", $nssm.App, "confirm"
    } else {
        Write-Host -Object "The service for", $nssm.DisplayName, "is not present."
    }
    if (Get-Command -Name Get-NetFirewallRule -ErrorAction SilentlyContinue) {
        if (Get-NetFirewallRule -DisplayName $nssm.DisplayName -ErrorAction SilentlyContinue) {
            Write-Host -Object "Removing firewall rules for", $nssm.DisplayName, "..."
            Remove-NetFirewallRule -DisplayName $nssm.DisplayName
        } else {
            Write-Host -Object "The firewall rules for", $nssm.DisplayName, "are not present."
        }
    } else {
        [string] $Program = $nssm.Application
        [string] $Name = $nssm.DisplayName
        $ShowRule = netsh advfirewall firewall show rule name="$Name"
        if ($ShowRule -match "$Name") {
            Write-Host -Object "Removing firewall rules for", $nssm.DisplayName, "..."
            Start-Process -FilePath "netsh" -ArgumentList ("advfirewall", "firewall", "delete", "rule", "name=`"$Name`"") -WindowStyle Hidden -Wait
        } else {
            Write-Host -Object "The firewall rules for", $nssm.DisplayName, "are not present."
        }
    }
    if (Test-Path -Path $nssm.AppDirectory) {
        Write-Host -Object "Removing", $nssm.AppDirectory, "..."
        Remove-Item -Path $nssm.AppDirectory -Recurse -Force
    } else {
        Write-Host -Object "The directory for", $nssm.AppDirectory, "is not present."
    }
    remove_menu
}
Function nssm {
    Write-Host -Object ""
    if (Test-Path -Path (Join-Path -Path $nssm.directory -ChildPath $nssm.filename)) {
        Write-Host -Object "NSSM already installed."
    } else {
        if (-Not (Test-Path -Path $nssm.directory)) {
            Write-Host -Object "Creating the directory", $nssm.directory, "..."
            New-Item -ItemType Directory -Force -Path $nssm.directory
        }
        if (Test-Path -Path (Join-Path -Path $env:TEMP -ChildPath $nssm.filename)) {
            Write-Host -Object "Installing the file", $nssm.filename, "..."
            Copy-Item -Path (Join-Path -Path $env:TEMP -ChildPath $nssm.filename) -Destination (Join-Path -Path $nssm.directory -ChildPath $nssm.filename)
        } else {
            Write-Host -Object "Please transfer files first."
        }
    }
    menu
}
Function steamcmd {
    Write-Host -Object ""
    if (Test-Path -Path (Join-Path -Path $steamcmd.directory -ChildPath $steamcmd.filename)) {
        Write-Host -Object "SteamCMD already installed."
    } else {
        if (-Not (Test-Path -Path $steamcmd.directory)) {
            Write-Host -Object "Creating the directory", $steamcmd.directory, "..."
            New-Item -ItemType Directory -Force -Path $steamcmd.directory
        }
        if (Test-Path -Path (Join-Path -Path $env:TEMP -ChildPath $steamcmd.filename)) {
            Write-Host -Object "Installing the file", $steamcmd.filename, "..."
            Copy-Item -Path (Join-Path -Path $env:TEMP -ChildPath $steamcmd.filename) -Destination (Join-Path -Path $steamcmd.directory -ChildPath $steamcmd.filename)
        } else {
            Write-Host -Object "Please transfer files first."
        }
    }
    if (Get-Command -Name Get-NetFirewallRule -ErrorAction SilentlyContinue) {
        if (Get-NetFirewallRule -DisplayName "SteamCMD" -ErrorAction SilentlyContinue) {
            Write-Host -Object "The firewall rule for SteamCMD is present."
        } else {
            Write-Host -Object "Adding firewall rule for SteamCMD ..."
            New-NetFirewallRule -DisplayName "SteamCMD" `
                                -Program (Join-Path -Path $steamcmd.directory -ChildPath $steamcmd.filename) `
                                -Direction Outbound -Action Allow
        }
    } else {
        [string] $Program = (Join-Path -Path $steamcmd.directory -ChildPath $steamcmd.filename)
        [string] $Name = "SteamCMD"
        $ShowRule = netsh advfirewall firewall show rule name="$Name"
        if ($ShowRule -match "$Name") {
            Write-Host -Object "The firewall rule for SteamCMD is present."
        } else {
            Write-Host -Object "Adding firewall rule for SteamCMD ..."
            Start-Process -FilePath "netsh" -ArgumentList ("advfirewall", "firewall", "add", "rule", "name=`"$Name`"", "program=`"$Program`"", "dir=out", "action=allow", "profile=any", "enable=yes") -WindowStyle Hidden -Wait
        }
    }
    menu
}
Function ntds {
    Write-Host -Object ""
    if (Test-Path -Path $nssm.Application) {
        Write-Host -Object $nssm.DisplayName ,"already installed."
    } else {
        if (-Not (Test-Path -Path (Join-Path -Path $steamcmd.directory -ChildPath $steamcmd.filename))) {
            Write-Host -Object "You need to install SteamCMD first!"
            menu
        } else {
            Write-Host -Object "Installing", $nssm.DisplayName, "..."
            $command = Join-Path -Path $steamcmd.directory -ChildPath "steamcmd.exe"
            Start-Process -FilePath $command -WorkingDirectory $steamcmd.directory -Wait `
                          -ArgumentList "+login anonymous", "+app_update 313600", "+validate", "+quit"
        }
    }
    if (-Not (Test-Path -Path (Join-Path -Path $nssm.directory -ChildPath $nssm.filename))) {
        Write-Host -Object "You need to install NSSM first!"
        menu
    } else {
        if (-Not (Get-Service -Name $nssm.App -ErrorAction SilentlyContinue)) {
            Write-Host -Object "Installing service for", $nssm.DisplayName, "..."
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
            Write-Host -Object "The service for", $nssm.DisplayName, "is present."
        }
    }
    if (Get-Command -Name Get-NetFirewallRule -ErrorAction SilentlyContinue) {
        if (-Not (Get-NetFirewallRule -DisplayName $nssm.DisplayName -ErrorAction SilentlyContinue)) {
            Write-Host -Object "Adding firewall rules for", $nssm.DisplayName, "..."
            New-NetFirewallRule -DisplayName $nssm.DisplayName -Program $nssm.Application `
                                -Direction Outbound -Action Allow
            New-NetFirewallRule -DisplayName $nssm.DisplayName -Program $nssm.Application `
                                -Direction Inbound -Action Allow
        } else {
            Write-Host -Object "The firewall rules for", $nssm.DisplayName, "are present."
        }
    } else {
        [string] $Program = $nssm.Application
        [string] $Name = $nssm.DisplayName
        $ShowRule = netsh advfirewall firewall show rule name="$Name"
        if ($ShowRule -match "$Name") {
            Write-Host -Object "The firewall rules for", $nssm.DisplayName, "are present."
        } else {
            Write-Host -Object "Adding firewall rules for", $nssm.DisplayName, "..."
            Start-Process -FilePath "netsh" -ArgumentList ("advfirewall", "firewall", "add", "rule", "name=`"$Name`"", "program=`"$Program`"", "dir=in", "action=allow", "profile=any", "enable=yes") -WindowStyle Hidden -Wait
            Start-Process -FilePath "netsh" -ArgumentList ("advfirewall", "firewall", "add", "rule", "name=`"$Name`"", "program=`"$Program`"", "dir=out", "action=allow", "profile=any", "enable=yes") -WindowStyle Hidden -Wait
        }
    }
    menu
}
menu
