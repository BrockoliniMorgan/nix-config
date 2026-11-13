{ userName, ... }:
{
  environment.persistence."/persistent".users.${userName}.directories = [
    ".config/vesktop"
    ".config/kicad"
    ".config/BraveSoftware"
    ".local/share/PrismLauncher"
    ".local/share/Steam"
    ".wine"
  ];
}
