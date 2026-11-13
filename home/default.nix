{
  inputs,
  pkgs,
  ...
}:
{
  imports = [
    ./home.nix
    ./packages.nix
    ./tmux.nix
    inputs.nvf.homeModules.nvf
  ];
  programs.nvf = {
    defaultEditor = true;
    settings.vim = import ./neovim { inherit pkgs; };
  };
}
