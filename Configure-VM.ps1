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

# Install the module from PowerShell Gallery
Install-Module -Name PSWindowsUpdate

# Run Windows Updates and reboot
Get-WUInstall -AcceptAll -AutoReboot



# Create unattend.xml at an obvious location in the file system.
Set-Location -Path C:\
New-Item -Name unattend.xml

$unattendxml = @"
<?xml version="1.0" encoding="utf-8"?>
<unattend xmlns="urn:schemas-microsoft-com:unattend">
    <settings pass="generalize">
        <component name="Microsoft-Windows-Security-SPP" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <SkipRearm>1</SkipRearm>
        </component>
        <component name="Microsoft-Windows-PnpSysprep" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <PersistAllDeviceInstalls>false</PersistAllDeviceInstalls>
            <DoNotCleanUpNonPresentDevices>false</DoNotCleanUpNonPresentDevices>
        </component>
    </settings>
    <settings pass="oobeSystem">
        <component name="Microsoft-Windows-International-Core" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <InputLocale>en-US</InputLocale>
            <SystemLocale>en-US</SystemLocale>
            <UILanguage>en-US</UILanguage>
            <UserLocale>en-US</UserLocale>
        </component>
        <component name="Microsoft-Windows-Shell-Setup" processorArchitecture="amd64" publicKeyToken="31bf3856ad364e35" language="neutral" versionScope="nonSxS" xmlns:wcm="http://schemas.microsoft.com/WMIConfig/2002/State" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
            <OOBE>
                <HideEULAPage>true</HideEULAPage>
                <ProtectYourPC>1</ProtectYourPC>
                <NetworkLocation>Home</NetworkLocation>
                <HideWirelessSetupInOOBE>true</HideWirelessSetupInOOBE>
            </OOBE>
            <TimeZone>UTC</TimeZone>
            <UserAccounts>
                <AdministratorPassword>
                    <Value>vagrant</Value>
                    <PlainText>true</PlainText>
                </AdministratorPassword>
                <LocalAccounts>
                    <LocalAccount wcm:action="add">
                        <Password>
                            <Value>vagrant</Value>
                            <PlainText>true</PlainText>
                        </Password>
                        <Group>administrators</Group>
                        <DisplayName>Vagrant</DisplayName>
                        <Name>vagrant</Name>
                        <Description>Vagrant User</Description>
                    </LocalAccount>
                </LocalAccounts>
            </UserAccounts>
        </component>
    </settings>
    <settings pass="specialize">
    </settings>
</unattend>
"@

Add-Content C:/unattend.xml $unattendxml

# Set the current working directory to be the Sysprep folder.
Set-Location -Path C:\Windows\System32\Sysprep
# Generalize the image and shutdown
.\sysprep.exe /generalize /oobe /unattend:C:/unattend.xml /shutdown