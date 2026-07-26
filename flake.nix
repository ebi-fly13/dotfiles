{
  description = "dotfiles (NixOS-WSL + fish)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
  };

  outputs = { self, nixpkgs, nixos-wsl, vscode-server, ... }:
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-wsl.nixosModules.default
          vscode-server.nixosModules.default
          ./nixos/configuration.nix
        ];
      };

      packages.x86_64-linux.default =
        self.nixosConfigurations.nixos.config.system.build.toplevel;
    };
}
