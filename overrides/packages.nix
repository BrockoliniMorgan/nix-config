final: prev:
let
  inherit (prev) lib;
in
{
  alacritty = final.callPackage ./alacritty.nix { };
  hyprland = (prev.hyprland.override { withUWSM = false; }).overrideAttrs (
    {
      env ? { },
      cmakeFlags ? [ ],
      ...
    }:
    {
      env = env // {
        NIX_CFLAGS_COMPILE = (env.NIX_CFLAGS_COMPILE or "") + " -Os";
      };
      cmakeFlags = cmakeFlags ++ [ (lib.cmakeBool "NO_HYPRPM" true) ];
    }
  );
  rofi-unwrapped = prev.rofi-unwrapped.override { x11Support = false; };
  tree = prev.pkgsStaticOptimised.tree;
  waybar = prev.waybar.override {
    niriSupport = false;
    cavaSupport = false;
    jackSupport = false;
    pulseSupport = false;
    pipewireSupport = false;
    sndioSupport = false;
    mpdSupport = false;
  };
  mako = prev.mako.override {
    withFishCompletions = false;
    withZshCompletions = false;
  };
  systemd = prev.systemd.override { withBootloader = false; };
  ly = prev.ly.override {
    x11Support = false;
  };
  pipewire = prev.pipewire.override { x11Support = false; };
  xdg-desktop-portal-gtk = prev.xdg-desktop-portal-gtk.overrideAttrs (
    {
      mesonFlags ? [ ],
      buildInputs ? [ ],
      ...
    }:
    {
      mesonFlags = mesonFlags ++ [
        (lib.mesonEnable "wallpaper" false)
        (lib.mesonEnable "settings" false)
      ];
      buildInputs = lib.remove "gsettings-desktop-schemas" (lib.remove "gnome-desktop" buildInputs);
    }
  );
  vim = prev.pkgsStatic.vim.overrideAttrs (
    {
      env ? { },
      ...
    }:
    {
      env.NIX_CFLAGS_COMPILE = (env.NIX_CFLAGS_COMPILE or "") + " -Os -flto";
    }
  );
  bat = prev.pkgsStatic.bat;
}
