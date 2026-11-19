{ userName, ... }:
{
  boot.initrd.systemd.services.impermanence-btrfs = {
    wantedBy = [ "initrd.target" ];
    after = [ "systemd-cryptsetup@cryptroot.service" ];
    before = [ "sysroot.mount" ];
    requiredBy = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /btrfs_tmp
      mount /dev/mapper/cryptroot /btrfs_tmp
      if [[ -d /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi
      btrfs subvolume create /btrfs_tmp/root

      find /btrfs_tmp/old_roots -mindepth 1 -maxdepth 1 -mtime +7 -exec btrfs subvolume delete -R {} \;

      umount /btrfs_tmp
      rm -rf /btrfs_tmp
    '';
  };

  environment.persistence."/persistent" = {
    enable = true;
    hideMounts = true;
    directories = [
      "/var/log"
      "/var/lib/bluetooth"
      "/var/lib/nixos"
      "/var/lib/systemd/coredump"
      "/etc/NetworkManager/system-connections"
      "/var/lib/docker"
      "/etc/ssh/"
    ];
    files = [
      "/etc/machine-id"
    ];
    users.${userName} = {
      directories = [
        "nix-config"
        ".ssh"
        ".config/sops"
        "Projects"
        "Documents"
        ".local/share/devenv"
        ".local/share/direnv"
      ];
    };
  };

  # Every reboot the lecture is given, getting annoying
  security.sudo.extraConfig = ''
    Defaults lecture = never
  '';
}
