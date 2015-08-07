NEOTOKYO Dedicated Server Installer
===================================

Requirements
------------
* 64-Bit Operating System (Windows 7/8/8.1/10, Windows Server 2008/2008 R2/2012/2012 R2/2016)
* Run as Administrator
* SteamCMD - Steam Console Client (steamcmd.exe)
* NSSM - the Non-Sucking Service Manager (nssm.exe)

Core Server Installation Guide
------------------------------

On the Core Server use `sconfig` to enable Remote Management.

	C:\Users\Administrator> sconfig
	[...]
	4) Configure Remote Management

On your Workstation ensure that the server is in `TrustedHosts`,
where `fqdn` is the full qualified domain name of your server,
if you are not in the same Windows DOMAIN.

	C:\> winrm get winrm/config/client
	C:\> winrm set winrm/config/client '@{TrustedHosts="fqdn"}'

Connect to the Server with `winrs -r:fqdn -U:Username -P:Password cmd`.

	C:\> winrs -r:fqdn -U:Username -P:Password cmd

If you do not have an accessable network share on the server, use the
following commands to create one.

	C:\Users\Administrator> netsh advfirewall firewall set rule group=”File and Printer Sharing” new enable=Yes
	C:\Users\Administrator> net share Public=%Public% /grant:everyone,FULL

Copy all files to the server network share `\\fqdn\Pubic\Downloads` confirmed your credentials for the share.

Remove the network share and disable the firewall acception.

	C:\Users\Administrator> net share Public /delete /y
	C:\Users\Administrator> netsh advfirewall firewall set rule group=”File and Printer Sharing” new enable=No

Run the Install Script on the server.

	C:\Users\Administrator> cd %Public%\Downloads
	C:\Users\Public\Downloads> dir
	[...]
	07.08.2015  02:34    <DIR>          .
	07.08.2015  02:34    <DIR>          ..
	07.08.2015  03:24             6.687 install.cmd
	05.08.2015  04:42           331.264 nssm.exe
	07.08.2015  04:06             2.770 readme.txt
	03.12.2013  11:10         1.687.464 steamcmd.exe
	[...]
	C:\Users\Public\Downloads> install.cmd
	-- NEOTOKYO Dedicated Server Installer --

	1) Install SteamCMD
	2) Install NSSM
	3) Install NEOTOKYO Dedicated Server
	4) Register Service
	5) Add Firewall Rules

	Select an Operation:

License
-------
NSSM is public domain. You may unconditionally use it and/or its source code for
any purpose you wish.

Steam and other Valve products distributed via Steam use certain third party
materials that require notifications about their license terms. You can find
a list of these notifications in the file called ThirdPartyLegalNotices.doc
distributed with the Steam client. Where license terms require Valve to make
source code available for redistribution, the code may be found at Valve Open Source.

Links
-----
* https://developer.valvesoftware.com/wiki/SteamCMD
* http://www.nssm.cc
