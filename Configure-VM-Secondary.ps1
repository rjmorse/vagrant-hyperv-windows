Install-WindowsFeature containers

#default to powershell
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name Shell -Value 'PowerShell.exe -NoExit'
#Now need to restart computer



Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force

#unsure about this next line
Set-PackageSource -Name DockerDefault -NewName DockerDefault-Trusted -Trusted -ProviderName DockerMsftProvider

# -Confirm:$false or perhaps use -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force 

get-service *docker*
docker system info
docker pull microsoft/nanoserver:1709