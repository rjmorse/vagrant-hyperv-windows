$ErrorActionPreference = "Stop"
Import-Module Hyper-V

$VMName = "WindowsServer1709-Containers"
$ISO = "C:\images\en_windows_server_version_1709_x64_dvd_100090904.iso"
$SwitchName = "External" # Substitute with the name of your VMSwitch.
$CPUCount = 4

Get-VMSwitch $SwitchName | Out-Null

# The configuration of our new VM.
$newVmArgs = @{
  "Name" = $VMName;
  "MemoryStartupBytes" = 4GB;
  "BootDevice" = "VHD";
  "Path" = "C:\Hyper-V\$VMName\";
  "NewVHDSizeBytes" = 30GB;
  "NewVHDPath" = "C:\Hyper-V\$VMName\Virtual Hard Disks\$VMName.vhdx"
  "Generation" = 2;
  "Switch" = $SwitchName; 
}
 
# Create the VM.
$vm = New-VM @newVmArgs 
Set-VMProcessor -VMName $VMName -Count $CPUCount

# Mount our installation media (.iso) on the VM.
Add-VMDvdDrive -VMName $VMName -Path $ISO
 
# Start VM
$vm | Start-VM