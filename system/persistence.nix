{ userName, ... }:
{
  boot.initrd.systemd.services.impermanence-btrfs = {
    after = [ "systemd-cryptsetup@cryptroot.service" ];
    before = [ "sysroot.mount" ];
    requiredBy = [ "sysroot.mount" ];
    unitConfig.DefaultDependencies = "no";
    serviceConfig.Type = "oneshot";
    script = ''
      mkdir -p /btrfs_tmp
      mount /dev/mapper/cryptroot /btrfs_tmp
      echo "Btrfs root mounted"

      delete_subvolume_recursively() {
        echo "Deleting subvolume $i"
        IFS=$'\n'
        for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
          delete_subvolume_recursively "/btrfs_tmp/$i"
        done
        btrfs subvolume delete "$1"
      }

      echo "Deleting old subvolumes"
      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +7); do
        delete_subvolume_recursively "$i"
      done

      if [[ -d /btrfs_tmp/root ]]; then
        echo "Root exists"
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date "+%Y-%m-%-d_%H:%M:%S")
        echo "Creating root for timestamp: $timestamp"
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi
      echo "Creating next root"
      btrfs subvolume create /btrfs_tmp/root

      echo "Unmounting"
      umount /btrfs_tmp
      echo "Deleting mountpoint"
      rm -rf /btrfs_tmp
      echo "Finished"
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
