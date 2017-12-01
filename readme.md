# About
>This will produce a Windows Server 1709 image to be used for Vagrant with the Hyper-V provider. It includes some manual steps, but produces a workable image

# Current status
- Creates a Vagrant box that you can use to `vagrant up`
- No ability to RDP, but you can connect via Hyper-V Server Manager as Administrator with password `vagrant`
- Tested with Vagrant 1.9.8 on on November 19, 2017
- Takes roughly 4 minutes to `vagrant up`

# Requirements
- Hyper-V role with External vSwitch (assumed to be named `External` but can easily be changed in scripts)
- ISO media for installing Windows Server 1709
- Roughly 50GB free space for development of box
  - 15GB for instance VHDX
  - 15GB for tarred VHDX file
  - 15GB for final box file
  - 5GB for subsequent instances created by Vagrant with differencing disks
- Roughly 20GB free space for using box
  - 15GB for box
  - Additional free space for instances and room to add features

# Usage
- Run `Create-VM.ps1` to create VM and start installation
- VM: 
  - Manually step through Windows installation
  - Use notepad to create a file with contents of `00-Configure-VM.ps1`
  - In a Powershell session, execute `00-Configure-VM.ps1`
  - Then, run these:
    - Powershell default shell: `01-Configure-VM-Added-Pass-1.ps1`
    - Add docker and base 1709 images: `02-Configure-VM-Added-Pass-2.ps1`
  - Execute to sysprep and shutdown: `03-Configure-VM-Final.ps1`
  - Wait for script to finish executing and VM to shut down
- Run `Capture-Box.ps1`
- Use vagrant with this new box named `WindowsServer1709-Containers`

# Example Vagrantfile

**Note the following:**
- vSwitch name and Vagrant box name are both specified
- `./provision.ps1` is for any commands to run as part of provisioning the box
- `h.vmname = "worker"` sets the name of the instance  in Hyper-V Server Manager

```
$VirtualSwitchName = "External"

IMAGE = "WindowsServer1709-Containers"

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