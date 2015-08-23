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

* Windows 7 Service Pack 1
* Windows Server 2008 R2 Service Pack 1
* Windows Server 2008 Service Pack 2
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

	Select number & press enter:

## License Information

NSSM is public domain. You may unconditionally use it and/or its source code for any purpose you wish.

Steam and other Valve products distributed via Steam use certain third party materials that require notifications about their license terms. You can find a list of these notifications in the file called ThirdPartyLegalNotices.doc distributed with the Steam client. Where license terms require Valve to make source code available for redistribution, the code may be found at Valve Open Source.
