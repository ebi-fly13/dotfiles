{
  description = "dotfiles (NixOS-WSL + fish)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    wslwrap-fish = {
      url = "github:drop-stones/wslwrap.fish";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, vscode-server, wslwrap-fish, ... }:
    let
      # 個人用の設定(fish ファイルなど、nix コードではなくただのファイル)
      # は別の private repo で管理し、personal
      # ビルドの時だけ取得する。builtins.fetchGit は遅延評価されるため、
      # nixosConfigurations.nixos を評価・ビルドする分にはこの private repo への
      # アクセス権は不要(personal を評価した時だけ実際にフェッチされる)。
      # repo 作成後、url と rev(固定コミット)をここに設定する。
      personalConfigUrl = "git@github.com:ebi-fly13/dotfiles-private.git";
      personalConfigRev = "67cb9c4cb7eaddf63bd84b87274641d3158a8cd5";
      personalConfigPath =
        if personalConfigUrl == null || personalConfigRev == null then
          throw "personal ビルドには private repo への push が必要です。flake.nix の personalConfigUrl/personalConfigRev を設定してください。"
        else
          builtins.fetchGit {
            url = personalConfigUrl;
            ref = "main";
            rev = personalConfigRev;
          };

      mkNixosConfiguration = { username, personalConfigPath ? null }: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit username personalConfigPath wslwrap-fish; };
        modules = [
          nixos-wsl.nixosModules.default
          vscode-server.nixosModules.default
          ./nixos/configuration.nix
        ];
      };
    in
    {
      nixosConfigurations.nixos = mkNixosConfiguration { username = "ebi"; };
      nixosConfigurations.personal = mkNixosConfiguration {
        username = "nixos";
        inherit personalConfigPath;
      };

      packages.x86_64-linux.default =
        self.nixosConfigurations.nixos.config.system.build.toplevel;
    };
}
