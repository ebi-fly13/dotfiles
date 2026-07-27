{ pkgs, lib, ... }:

{
  nixpkgs.config.allowUnfreePredicate =
    pkg: builtins.elem (lib.getName pkg) [ "claude-code" ];

  environment.systemPackages = with pkgs; [
    git
    ripgrep
    fd
    bat
    eza
    claude-code
    gcc
    gnumake
    clang
    rustc
    cargo
  ];
}
