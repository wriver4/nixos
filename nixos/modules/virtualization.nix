{ config, pkgs, ... }:

{
  config = {
  virtualisation.libvirtd.enable = true;

  virtualisation.docker.enable = true;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  environment.systemPackages = with pkgs; [
    docker-buildx
    virt-manager
    virt-viewer
    qemu_kvm
  /* 
   #microvm
    */
  ];
  /*
   # Container lxd lxc
   # virtualisation.lxd.enable = true;
   # virtualisation.lxd.ui.enable = true;
   # virtualisation.lxc.lxcfs.enable = true;
  */
  };
}
