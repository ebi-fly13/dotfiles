{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    ripgrep
    fd
    bat
    eza
  ];
}
