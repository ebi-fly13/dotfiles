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
- `nixos/modules/ssh.nix` — Windows 側 1Password の SSH エージェントを WSL に橋渡しする
  `SSH_AUTH_SOCK` 設定。RSA 鍵の実体は 1Password が管理する。
- `nixos/modules/vscode-server.nix` — Remote-WSL 用の `services.vscode-server` 設定。

## 1Password SSH エージェント連携

1. Windows 側の 1Password アプリで Settings → Developer → "Use the SSH agent" を有効化し、
   WSL integration を ON にする(`~/.1password/agent.sock` が各 WSL ディストロに公開される)。
2. `nixos-rebuild switch` 後、新しいシェルで `echo $SSH_AUTH_SOCK` がそのパスを指していることを確認する。
3. `ssh-add -l` で 1Password 管理下の鍵が見えれば OK。

## 新しい NixOS-WSL 環境に持っていく場合

1. [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) を `wsl --import` 等でインストール。
2. このリポジトリを `/home/ebi/dotfiles` に配置(git clone、または他のディストロから
   `tar -cf - . | wsl.exe -d <distro> -- tar -C /home/ebi/dotfiles -xf -` などで転送)。
3. `sudo nixos-rebuild switch --flake .#nixos` を実行。
