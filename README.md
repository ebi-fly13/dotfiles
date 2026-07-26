# dotfiles

WSL 上の NixOS (NixOS-WSL) 用システム設定。デフォルトシェルを fish にし、
最低限のシェルツール(ripgrep, fd, bat, eza, fzf, zoxide)をシステムに入れる。

home-manager は使わず、すべて `nixos/configuration.nix` の system レベル設定
(`environment.systemPackages`, `programs.*`)で完結させている。

## 前提

- このリポジトリは NixOS-WSL ディストロ内の `/home/ebi/dotfiles` に置いて使う。
- `nixosConfigurations.nixos` の `wsl.defaultUser` は `ebi`。

## 設定を反映する

```fish
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#nixos
```

`nixos/configuration.nix` を編集してから上記を実行すれば変更が反映される。

## 構成

- `flake.nix` — `nixos-wsl` と `nixpkgs` の2 input のみ。`nixosConfigurations.nixos` を出力。
- `nixos/configuration.nix` — WSL 有効化・ユーザー(`ebi`, shell = fish)・
  system パッケージ・fish/zoxide 設定。

## 新しい NixOS-WSL 環境に持っていく場合

1. [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) を `wsl --import` 等でインストール。
2. このリポジトリを `/home/ebi/dotfiles` に配置(git clone、または他のディストロから
   `tar -cf - . | wsl.exe -d <distro> -- tar -C /home/ebi/dotfiles -xf -` などで転送)。
3. `sudo nixos-rebuild switch --flake .#nixos` を実行。
