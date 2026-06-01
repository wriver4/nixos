{ pkgs, ... }:

{
  config = {
    environment.systemPackages = with pkgs; [
      pciutils # lspci
      usbutils # lsusb
      dmidecode # hardware info from BIOS/UEFI (DMI/SMBIOS)
      inetutils # ping, telnet, ftp, rcp, rlogin, rsh, rwho, tftp, rcp
      smartmontools # for `smartctl` command

      # filesystems and recovery
      ntfs3g # NTFS filesystem support
      dosfstools # tools for creating and checking MS-DOS FAT filesystems
      exfatprogs # tools for creating and checking exFAT filesystems
      scrounge-ntfs # tools for recovering files from damaged NTFS filesystems
      
      # provisioning
      disko # Declarative disk partitioning and formatting using nix

      # low level tools
      binutils # A collection of binary tools
      testdisk # Data recovery software
    ];
  };
}
