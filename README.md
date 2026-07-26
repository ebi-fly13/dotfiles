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

- `flake.nix` — `nixos-wsl`・`nixpkgs`・`vscode-server` の input。`nixosConfigurations.nixos` を出力。
- `nixos/configuration.nix` — WSL 有効化・ユーザー(`ebi`, shell = fish)・
  `system.stateVersion` などトップレベル設定。各モジュールを import する。
- `nixos/modules/shell-tools.nix` — git, ripgrep, fd, bat, eza など汎用 CLI ツール。
- `nixos/modules/fish.nix` — fish 本体・fzf/fzf-fish・zoxide・tide のシェル統合設定。
- `nixos/modules/git.nix` — `/etc/gitconfig` の宣言的設定(user, core, init など)。
  `core.sshCommand` で Windows 側 `ssh.exe` を使う。
- `nixos/modules/ssh.nix` — シェルの `ssh` コマンドを Windows 側 `ssh.exe`
  (`/mnt/c/Windows/System32/OpenSSH/ssh.exe`) に alias する。RSA 鍵は 1Password が
  管理し、`ssh.exe` が Windows 側の 1Password SSH エージェント(named pipe)を直接使うため、
  WSL 側でソケットを橋渡しする設定は不要。
- `nixos/modules/vscode-server.nix` — Remote-WSL 用の `services.vscode-server` 設定。

## 1Password SSH エージェント連携

1. Windows 側の 1Password アプリで Settings → Developer → "Use the SSH agent" を有効化する。
2. `nixos-rebuild switch` 後、新しいシェルで `ssh.exe -T git@github.com` 等が
   1Password 管理下の鍵で認証できることを確認する(git 操作は `core.sshCommand` 経由で
   自動的に `ssh.exe` を使う)。

## 新しい NixOS-WSL 環境に持っていく場合

1. [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) を `wsl --import` 等でインストール。
2. このリポジトリを `/home/ebi/dotfiles` に配置(git clone、または他のディストロから
   `tar -cf - . | wsl.exe -d <distro> -- tar -C /home/ebi/dotfiles -xf -` などで転送)。
3. `sudo nixos-rebuild switch --flake .#nixos` を実行。
