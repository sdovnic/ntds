# NEOTOKYO Dedicated Server Installer

Installation Script for easy deploying an NEOTOKYO Dedicated Server on Windows.

NEOTOKYO is a multiplayer first person shooter that provides a visceral & realistic combat experience in a rich futuristic setting.

## Requirements

* 64-Bit Windows Operating System
* [PowerShell](https://www.microsoft.com/en-us/download/details.aspx?id=34595) 3.0
* Elevated Command Prompt
* [SteamCMD](https://developer.valvesoftware.com/wiki/SteamCMD) - Steam Console Client (steamcmd.exe)
* [NSSM](http://www.nssm.cc) - the Non-Sucking Service Manager (nssm.exe)

## Supported 64-Bit Operating Systems

* Windows 8
* Windows 8.1
* Windows 10
* Windows Server 2012
* Windows Server 2012 R2
* Windows Server 2016 Technical Preview

## Core Server Installation Guide

If not enabled, use `sconfig` on your server to enable Remote Management.

	C:\Users\Administrator> sconfig
	[...]
	4) Configure Remote Management

If you are not in the same Windows DOMAIN as your server, ensure that the server is in `TrustedHosts`, where `fqdn` is the full qualified domain name of your server.

	C:\> winrm get winrm/config/client
	C:\> winrm set winrm/config/client '@{TrustedHosts="fqdn"}'

## Usage

For Installation run the `install.cmd` script.

Please be patient after you selected installing `3. NEOTOKYO Dedicated Server`, depending on your internet connection it may take a while.

	-- NEOTOKYO Dedicated Server Installer --

	1. Remote Installation
	2. Local Installation

	Select number & press enter: 1

	Please enter the full qualified domain name of your remote host:

	Cmdlet Get-Credential an der Befehlspipelineposition 1
	Geben Sie Werte für die folgenden Parameter an:
	Credential

	Starting remote installation ...

	-- NEOTOKYO Dedicated Server Installer --

	1. SteamCMD - Steam Console Client
	2. NSSM - the Non-Sucking Service Manager
	3. NEOTOKYO Dedicated Server

	Select number & press enter: 1

	Installing the file steamcmd.exe ...
	The firewall rule for SteamCMD is present.

	1. SteamCMD - Steam Console Client
	2. NSSM - the Non-Sucking Service Manager
	3. NEOTOKYO Dedicated Server

	Select number & press enter: 2

	Installing the file nssm.exe ...

	1. SteamCMD - Steam Console Client
	2. NSSM - the Non-Sucking Service Manager
	3. NEOTOKYO Dedicated Server

	Select number & press enter: 3

	Installing NEOTOKYO Dedicated Server ...
	Installing service for NEOTOKYO Dedicated Server ...
	The firewall rules for NEOTOKYO Dedicated Server are present.

	1. SteamCMD - Steam Console Client
	2. NSSM - the Non-Sucking Service Manager
	3. NEOTOKYO Dedicated Server

	Select number & press enter:

	1. Remote Installation
	2. Local Installation

	Select number & press enter:

## Controlling the Server

Enter a remote PowerShell session:

	Enter-PSSession -ComputerName <fqdn> -Credential $credential

Get the service status:

	Get-Service neotokyo

Start the service:

	Set-Service neotokyo -Status Running

Edit the server.cfg with the PowerShell ISE.

1. Open PowerShell ISE

	`powershell_ise`

2. Enter a remote session:

	`Enter-PSSession -ComputerName <fqdn> -Credential $credential`

3. Edit the server.cfg file with:

	`PSEdit 'C:\Program Files (x86)\SteamCMD\steamapps\common\NEOTOKYO Dedicated Server\NeotokyoSource\cfg\server.cfg'`

## License Information

NSSM is public domain. You may unconditionally use it and/or its source code for any purpose you wish.

Steam and other Valve products distributed via Steam use certain third party materials that require notifications about their license terms. You can find a list of these notifications in the file called ThirdPartyLegalNotices.doc distributed with the Steam client. Where license terms require Valve to make source code available for redistribution, the code may be found at Valve Open Source.
