{ config, pkgs, ... }:

{
  imports = [
    ./modules/shell-tools.nix
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/ssh.nix
    ./modules/vscode-server.nix
    ./modules/wezterm.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = "ebi";

  users.users.ebi = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  security.sudo.wheelNeedsPassword = false;

  system.stateVersion = "26.05";
}
