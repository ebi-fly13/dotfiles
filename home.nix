{ config, pkgs, ... }:

{
  home.stateVersion = "24.05";
  programs.home-manager.enable = true;

  imports = [
    ./modules/shell-tools.nix
    ./modules/fish.nix
  ];
}
