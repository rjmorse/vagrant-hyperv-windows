# The below is to be ran after Windows Setup is completed


# Disable UAC by setting the correct registry property.
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force

# Disable password complexity requirements. There isn't a PowerShell-like way of doing this at the moment, so we have to use secedit to export the
# configuration, replace a value and reapply it.
secedit /export /cfg .\secedit.cfg

(Get-Content -Path .\secedit.cfg).Replace("PasswordComplexity = 1", "PasswordComplexity = 0") | Out-File -FilePath .\secedit.cfg

secedit /configure /db C:\Windows\security\local.sdb /cfg .\secedit.cfg /areas SECURITYPOLICY

# Now that we've disabled password complexity, change the Administrator password to "vagrant". The docs recommend you use this standard password for boxes
# that you want to share with others.
net user Administrator vagrant

# If you've opted out of using the GUI version of Windows Server you can ignore the below commands.

# Disable shutdown reason dialog.
New-ItemProperty -Path "HKLM:Software\Microsoft\Windows\CurrentVersion\Reliability" -Name ShutdownReasonOn -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:Software\Microsoft\Windows\CurrentVersion\Reliability" -Name ShutdownReasonUI -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Reliability" -Name ShutdownReasonOn -PropertyType DWord -Value 0 -Force
New-ItemProperty -Path "HKLM:Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Reliability" -Name ShutdownReasonUI -PropertyType DWord -Value 0 -Force

# Disable ServerManager startup on login.
New-ItemProperty -Path HKLM:Software\Microsoft\ServerManager -Name DoNotOpenServerManagerAtLogon -PropertyType DWord -Value 1 -Force

# Enable Remote Desktop Connections
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -name fDenyTSConnections -PropertyType DWord -Value 0 -Force
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"


winrm quickconfig -q
winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="512"}'
winrm set winrm/config '@{MaxTimeoutms="1800000"}'
winrm set winrm/config/service '@{AllowUnencrypted="true"}'
winrm set winrm/config/service/auth '@{Basic="true"}'
Set-Service -Name WinRM -StartupType Automatic


# As this is a clean Windows Server we should install NuGet first.
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Make sure the PowerShell Gallery is a trusted repository
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted

