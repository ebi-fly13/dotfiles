# dotfiles

WSL 上の NixOS (NixOS-WSL) 用システム設定。デフォルトシェルを fish にし、
最低限のシェルツール(ripgrep, fd, bat, eza, fzf, zoxide)をシステムに入れる。

home-manager は使わず、すべて `nixos/configuration.nix` の system レベル設定
(`environment.systemPackages`, `programs.*`)で完結させている。

## 前提

- このリポジトリは NixOS-WSL ディストロ内の `/home/<username>/dotfiles` に置いて使う。
- flake は `nixosConfigurations` を2つ出力する。
  - `nixos` — 通常ビルド。ユーザー名は `ebi`。
  - `personal` — 個人ビルド。ユーザー名は `nixos`。個人用の設定
    (`fish/env.fish`、nix コードは置かない)は別の private repo
    (`dotfiles-private`)で管理し、`nixos-rebuild switch
    --flake .#personal` の評価時だけ取得される。読み込みロジック自体は
    このリポジトリの `nixos/modules/personal.nix` にある。`#nixos` の
    ビルドには private repo へのアクセス権は不要。

## 設定を反映する

```fish
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#nixos      # 通常ビルド(ebi)
sudo nixos-rebuild switch --flake .#personal   # 個人ビルド
```

`nixos/configuration.nix` を編集してから上記を実行すれば変更が反映される。

## 構成

- `flake.nix` — `nixos-wsl`・`nixpkgs`・`vscode-server` の input。
  `username` と `personalConfigPath`(personal ビルドの時だけ private repo
  を `builtins.fetchGit` で遅延取得したパス)を `specialArgs` 経由で渡し、
  `nixosConfigurations.nixos` / `nixosConfigurations.personal` を出力する。
- `nixos/configuration.nix` — WSL 有効化・ユーザー(shell = fish)・
  `system.stateVersion` などトップレベル設定。各モジュールを import する。
- `nixos/modules/personal.nix` — `personalConfigPath` が設定されている時
  だけ、private repo 内の `fish/env.fish` を fish 起動時に `source` する。
- `nixos/modules/shell-tools.nix` — git, ripgrep, fd, bat, eza, claude-code など汎用 CLI ツール。
- `nixos/modules/fish.nix` — fish 本体・fzf/fzf-fish・zoxide・tide のシェル統合設定。
- `nixos/modules/git.nix` — `/etc/gitconfig` の宣言的設定(user, core, init など)。
  `core.sshCommand` で Windows 側 `ssh.exe` を使う。
- `nixos/modules/ssh.nix` — シェルの `ssh` コマンドを Windows 側 `ssh.exe`
  (`/mnt/c/Windows/System32/OpenSSH/ssh.exe`) に alias する。RSA 鍵は 1Password が
  管理し、`ssh.exe` が Windows 側の 1Password SSH エージェント(named pipe)を直接使うため、
  WSL 側でソケットを橋渡しする設定は不要。
- `nixos/modules/vscode-server.nix` — Remote-WSL 用の `services.vscode-server` 設定。
- `nixos/modules/windows-interop.nix` — Windows 側の `powershell.exe` /
  `pwsh.exe` / `cmd.exe` を WSL から呼ぶ fish 関数(`powershell`, `pwsh`, `cmd`)。
  引数の WSL パスは自動で Windows パスに変換される。
- `nixos/modules/wezterm.nix` — WezTerm (Windows 側) から接続した際に渡ってくる
  `TERM=wezterm` をシェル側で認識できるよう、`pkgs.wezterm.terminfo` を導入する。
- `wezterm/wezterm.lua` — WezTerm (Windows 側) の設定。Windows のファイルなので
  Nix のビルド対象外。下記「WezTerm の設定」を参照。
- `autohotkey/wezterm-toggle.ahk` — WezTerm を前面に呼び出す/背面に隠す AutoHotkey
  スクリプト(Windows 側)。Nix のビルド対象外。下記「AutoHotkey の設定」を参照。

## 1Password SSH エージェント連携

1. Windows 側の 1Password アプリで Settings → Developer → "Use the SSH agent" を有効化する。
2. `nixos-rebuild switch` 後、新しいシェルで `ssh.exe -T git@github.com` 等が
   1Password 管理下の鍵で認証できることを確認する(git 操作は `core.sshCommand` 経由で
   自動的に `ssh.exe` を使う)。

## WezTerm の設定

WezTerm は Windows 側で動かし、`wsl_domains` 経由でこの NixOS-WSL ディストロに
接続する構成。設定ファイル `wezterm/wezterm.lua` は Windows のファイルシステム
(`%USERPROFILE%\.wezterm.lua`)に置く必要があるため、Nix では管理できない。
このリポジトリではファイル自体だけを git 管理し、Windows 側からシンボリック
リンクで読み込ませる。

PowerShell (開発者モード有効、または管理者権限で実行):

```powershell
New-Item -ItemType SymbolicLink -Path $env:USERPROFILE\.wezterm.lua `
  -Target \\wsl$\NixOS\home\ebi\dotfiles\wezterm\wezterm.lua
```

`wsl -l -v` で表示される distro 名が `NixOS` と異なる場合は、上記コマンドの
パスと `wezterm/wezterm.lua` 内の `distro` 変数を実際の名前に合わせて書き換える。

## AutoHotkey の設定

WezTerm には Windows Terminal の Quake モードのような表示/非表示トグル機能が
無く、`wezterm.lua` 側のキーバインドは WezTerm がフォーカスされている時しか
効かない(隠れている状態からは呼び出せない)。そのため Windows 側で
AutoHotkey v2 を使い、`autohotkey/wezterm-toggle.ahk` でフォーカス状態に
関係なく常に有効なグローバルホットキーを提供する。

- `Ctrl+Alt+Up` … WezTerm を前面に呼び出す(最小化していれば復元)
- `Ctrl+Alt+Down` … WezTerm を最小化して背面に隠す

セットアップ:

1. Windows に [AutoHotkey v2](https://www.autohotkey.com/) をインストールする。
2. `autohotkey/wezterm-toggle.ahk` をダブルクリックして実行するか、
   ログイン時に自動起動させたい場合はスタートアップフォルダにショートカット
   (または PowerShell でシンボリックリンク)を作成する。

```powershell
New-Item -ItemType SymbolicLink `
  -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\wezterm-toggle.ahk" `
  -Target \\wsl$\NixOS\home\ebi\dotfiles\autohotkey\wezterm-toggle.ahk
```

## 新しい NixOS-WSL 環境に持っていく場合

1. [NixOS-WSL](https://github.com/nix-community/NixOS-WSL) を `wsl --import` 等でインストール。
2. このリポジトリを `/home/ebi/dotfiles` に配置(git clone、または他のディストロから
   `tar -cf - . | wsl.exe -d <distro> -- tar -C /home/ebi/dotfiles -xf -` などで転送)。
3. `sudo nixos-rebuild switch --flake .#nixos` を実行。
