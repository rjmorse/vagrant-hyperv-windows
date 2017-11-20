# Hopefully you still have the PowerShell session from earlier, if not:
Import-Module Hyper-V
$ErrorActionPreference = "Stop"

$VMName = "WindowsServer1709-Containers"
$ExportPath = "C:\VagrantBoxes\"

$vm = Get-VM -Name $VMName

# We need to detach the DVD drive we used to mount the ISO earlier.
$vm | Get-VMDvdDrive | Remove-VMDvdDrive
 
# Export the VM to a known place
$vm | Export-VM -Path $ExportPath
 
# Switch to the export location
Set-Location -Path $ExportPath
 
# Take a look inside the exported VM directory
Get-ChildItem -Path .\$VMName
 
# There should be three subdirectories: Snapshots, Virtual Hard Disks and Virtual Machines.
# Vagrant ignores VM snapshots, so there's no point in boxing any up. Delete the directory.
Remove-Item -Path .\$VMName\Snapshots\


New-Item -Name .\$VMName\metadata.json -ItemType File

$metadata = @"
{
    "provider": "hyperv"
}
"@
Add-Content .\$VMName\metadata.json $metadata

Set-Location -Path .\$VMName
7z a "$VMName.tar" *
#Compress-Archive is not an option due to 2GB filesize limit/bug

vagrant box add $VMName .\$VMName.tar
