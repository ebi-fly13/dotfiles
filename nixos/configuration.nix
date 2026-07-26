{ config, pkgs, ... }:

{
  wsl.enable = true;
  wsl.defaultUser = "ebi";

  users.users.ebi = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  security.sudo.wheelNeedsPassword = false;

  environment.systemPackages = with pkgs; [
    ripgrep
    fd
    bat
    eza
    fzf
    fishPlugins.fzf-fish
  ];

  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -g fish_greeting
    '';
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };

  services.vscode-server = {
    enable = true;
    enableFHS = true;
    nodejsPackage = pkgs.nodejs_22;
  };

  system.stateVersion = "26.05";
}
