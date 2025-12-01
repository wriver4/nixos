{ config, pkgs, ... }:

{
  config = {

 #  Container lxd lxc
 # virtualisation.lxd.enable = true;
 # virtualisation.lxd.ui.enable = true;
 # virtualisation.lxc.lxcfs.enable = true;

 virtualisation.libvirtd.enable = true;

#  virtualisation.virtualbox.host.enable = true;
#  virtualisation.virtualbox.host.enableExtensionPack = true;
#  virtualisation.virtualbox.host.enableKvm = true;
#  users.extraGroups.vboxusers.members = [ "mark" "wheel" ];

  #virtualisation.podman.enable = true;
  #virtualisation.podman.dockerSocket.enable = true;
  #virtualisation.podman.defaultNetwork.settings.dns_enabled  = true;

  virtualisation.docker.enable = true;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;


  environment.systemPackages = with pkgs; [
  docker-buildx
  /*  virt-manager
    virt-viewer
    virt-top
    virt-install
    virt-what
    virt-v2v
    virt-p2v
    virt-df
    virt-ctrl
    virt-clone
    virt-convert
    virt-xml
    */

    #podman
    #podman-desktop
    #quickgui
    virt-manager
    virt-viewer
    #quickemu
    qemu_kvm
    #lxd-ui
    #devbox
    #microvm

    # python311Packages.podmam
    # virtualbox
    # linuxKernel.packages.linux_6_6.virtualbox 
    
  ];

  };
}
