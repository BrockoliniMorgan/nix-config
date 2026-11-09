{ pkgs, lib, ... }:
{
  networking.networkmanager.enable = true;
  programs.arp-scan.enable = true;
  programs.nano.enable = false;
  programs.vim.enable = true;
  services.fwupd.enable = true;
  services.openssh.enable = true;
  services.printing.enable = true;
  services.keyd.enable = true;

  environment.defaultPackages = lib.mkForce [ ];
  environment.systemPackages = with pkgs; [
    bat
    brightnessctl
    file
    iw
    nettools
    sops
    tree
    usbutils
    wget
  ];
}
