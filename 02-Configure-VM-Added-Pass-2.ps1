Install-Module -Name DockerMsftProvider -Repository PSGallery -Force

# -Confirm:$false or perhaps use -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -Force 
Start-Service *docker*

get-service *docker*
docker system info
docker pull microsoft/nanoserver:1709
docker pull microsoft/windowsservercore:1709