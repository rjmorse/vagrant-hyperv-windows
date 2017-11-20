# About
>This will produce a Windows Server 1709 image to be used for Vagrant with the Hyper-V provider. It includes some manual steps, but produces a workable image

# Current status
- Creates a Vagrant box that you can use to `vagrant up`
- No ability to RDP, but you can connect via Hyper-V Server Manager as Administrator with password `vagrant`

# Requirements
- Hyper-V role with External vSwitch (assumed to be named `External` but can easily be changed in scripts)
- ISO media for installing Windows Server 1709
- Roughly 25GB free space for development of box
  - 6GB for instance VHDX
  - 6GB for tarred VHDX file
  - 6GB for final box file
  - 5GB for subsequent instances created by Vagrant with differencing disks
- Roughly 10GB free space for using box
  - 6GB for box
  - Additional free space for instances and room to add features

# Usage
- Run `Create-VM.ps1` to create VM and start installation
- VM: 
  - Manually step through Windows installation
  - Use notepad to create a file with contents of `Configure-VM.ps1`
  - In a Powershell session, execute `Configure-VM.ps1`
  - Wait for script to finish executing and VM to shut down
- Run `Capture-Box.ps1`
- Use vagrant with this new box named `WindowsServer1709`

# Example Vagrantfile

**Note the following:**
- vSwitch name and Vagrant box name are both specified
- `./provision.ps1` is for any commands to run as part of provisioning the box
- `h.vmname = "worker"` sets the name of the instance  in Hyper-V Server Manager
```
$VirtualSwitchName = "External"

IMAGE = "WindowsServer1709"

Vagrant.configure("2") do |config|
    config.vm.define "worker" do |subconfig|
        subconfig.vm.box = IMAGE
        subconfig.vm.communicator = "winrm"
        subconfig.vm.hostname = "worker"
        subconfig.vm.network :public_network, bridge: $VirtualSwitchName
        subconfig.vm.synced_folder ".", "/vagrant", disabled: true
        subconfig.vm.provision "shell", path: "./provision.ps1", privileged: true
        subconfig.vm.provider "hyperv" do |h|
            h.enable_virtualization_extensions = true
            h.differencing_disk = true
            h.cpus = 4
            h.memory = 1024
            h.maxmemory = 4096
            h.vmname = "worker"
        end   
    end
end

```