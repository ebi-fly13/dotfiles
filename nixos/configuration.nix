{ config, pkgs, username, ... }:

{
  imports = [
    ./modules/shell-tools.nix
    ./modules/fish.nix
    ./modules/git.nix
    ./modules/personal.nix
    ./modules/ssh.nix
    ./modules/vscode-server.nix
    ./modules/wezterm.nix
    ./modules/windows-interop.nix
  ];

  wsl.enable = true;
  wsl.defaultUser = username;

  time.timeZone = "Asia/Tokyo";

  users.users.${username} = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.fish;
  };

  security.sudo.wheelNeedsPassword = false;
  # sudo 経由でも呼び出し元シェルの proxy 環境変数を引き継ぐ。
  security.sudo.extraConfig = ''
    Defaults env_keep += "http_proxy https_proxy ftp_proxy no_proxy HTTP_PROXY HTTPS_PROXY FTP_PROXY NO_PROXY"
  '';

  system.stateVersion = "26.05";
}
