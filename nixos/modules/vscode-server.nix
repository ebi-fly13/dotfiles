{ pkgs, ... }:

{
  services.vscode-server = {
    enable = true;
    enableFHS = true;
    nodejsPackage = pkgs.nodejs_22;
  };
}
