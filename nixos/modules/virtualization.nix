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
    podman
    podman-desktop
    quickgui
    quickemu
    lxd-ui
    microvm
    python311Packages.podmam
    */
  ];
  /*
   # Container lxd lxc
   # virtualisation.lxd.enable = true;
   # virtualisation.lxd.ui.enable = true;
   # virtualisation.lxc.lxcfs.enable = true;
  #virtualisation.podman.enable = true;
  #virtualisation.podman.dockerSocket.enable = true;
  #virtualisation.podman.defaultNetwork.settings.dns_enabled  = true;
  */
  };
}
