# dotfiles

WSL 上の NixOS (NixOS-WSL) 用システム設定。デフォルトシェルは fish、
最低限のシェルツール(ripgrep, fd, bat, eza, fzf, zoxide)を導入する。

home-manager は使わず、`nixos/configuration.nix` 以下の system レベル設定
(`environment.systemPackages`, `programs.*`)だけで完結させている。

このリポジトリは NixOS-WSL ディストロ内の `/home/<username>/dotfiles` に置いて使う。

## nixosConfigurations

- `nixos` — 通常ビルド。ユーザー名は `ebi`。
- `personal` — 個人ビルド。ユーザー名は `nixos`。個人用ファイル
  (`fish/env.fish` のみ、nix コードは置かない)を別の private repo
  (`dotfiles-private`)で管理し、ビルド時に `builtins.fetchGit` で取得する
  (読み込みロジックは `nixos/modules/personal.nix`)。`#nixos` のビルドに
  private repo へのアクセス権は不要。

## 設定を反映する

```fish
cd ~/dotfiles
sudo nixos-rebuild switch --flake .#nixos      # 通常ビルド(ebi)
sudo nixos-rebuild switch --flake .#personal   # 個人ビルド
```

`nixos/configuration.nix` を編集して上記を実行すれば変更が反映される。

**`#personal` が sudo で失敗する場合**: root から private repo を
`fetchGit` する際、この環境では稀に `ssh.exe: Invalid argument` で失敗する
(原因未特定、一般ユーザー権限では成功する)。その場合は build と
activate を分けて実行する:

```fish
nixos-rebuild build --flake .#personal
sudo ./result/bin/switch-to-configuration switch
```

## 構成

- `flake.nix` — `nixos-wsl`・`nixpkgs`・`vscode-server`・`wslwrap-fish` の
  input。`username` と `personalConfigPath` を `specialArgs` 経由で渡し、
  `nixosConfigurations.nixos` / `.personal` を出力する。
- `nixos/configuration.nix` — WSL 有効化・ユーザー(shell = fish)・
  `system.stateVersion` などのトップレベル設定。各モジュールを import する。
- `nixos/modules/personal.nix` — `personalConfigPath` 設定時のみ、private
  repo 内の `fish/env.fish` を fish 起動時に `source` する。
- `nixos/modules/shell-tools.nix` — git, ripgrep, fd, bat, eza, claude-code
  など汎用 CLI ツール。
- `nixos/modules/fish.nix` — fish 本体・fzf/fzf-fish・zoxide・tide。
- `nixos/modules/git.nix` — `/etc/gitconfig` の宣言的設定。
  `core.sshCommand` で Windows 側 `ssh.exe` を使う。
- `nixos/modules/ssh.nix` — シェルの `ssh` を Windows 側
  `/mnt/c/Windows/System32/OpenSSH/ssh.exe` に alias する。鍵は 1Password
  の SSH エージェント(named pipe)を `ssh.exe` が直接使うため、WSL 側での
  ソケット橋渡しは不要。
- `nixos/modules/vscode-server.nix` — Remote-WSL 用の `services.vscode-server`。
- `nixos/modules/windows-interop.nix` —
  [wslwrap.fish](https://github.com/drop-stones/wslwrap.fish) で
  `op` / `powershell` / `pwsh` / `cmd` を常に Windows 版 exe 実行に、`git` は
  `/mnt` 配下で Windows 版、それ以外で Linux 版に自動選択する。`which` も
  `wslwrap which` に alias してラッパーを解決できるようにする。`code` は
  Remote-WSL を避けてネイティブ `Code.exe` を直接起動する専用の fish 関数。
- `nixos/modules/wezterm.nix` — WezTerm 接続時に渡ってくる `TERM=wezterm`
  を認識できるよう `pkgs.wezterm.terminfo` を導入する。
- `wezterm/wezterm.lua` — WezTerm (Windows 側) の設定。Windows のファイル
  なので Nix のビルド対象外(「WezTerm の設定」参照)。
- `autohotkey/wezterm-toggle.ahk` — WezTerm 前面呼び出し/隠す AutoHotkey
  スクリプト(Windows 側、Nix のビルド対象外。「AutoHotkey の設定」参照)。

## 1Password SSH エージェント連携

1. Windows 側の 1Password アプリで Settings → Developer → "Use the SSH agent" を有効化する。
2. `nixos-rebuild switch` 後、新しいシェルで `ssh.exe -T git@github.com` 等が
   1Password 管理下の鍵で認証できることを確認する(git 操作は `core.sshCommand`
   経由で自動的に `ssh.exe` を使う)。

## WezTerm の設定

WezTerm は Windows 側で動かし、`wsl_domains` 経由でこの NixOS-WSL ディストロに
接続する。設定ファイル `wezterm/wezterm.lua` は Windows のファイルシステム
(`%USERPROFILE%\.wezterm.lua`)に置く必要があるため Nix では管理できず、
ファイル自体だけを git 管理して Windows 側からシンボリックリンクで読み込ませる。

PowerShell (開発者モード有効、または管理者権限で実行):

```powershell
New-Item -ItemType SymbolicLink -Path $env:USERPROFILE\.wezterm.lua `
  -Target \\wsl$\NixOS\home\ebi\dotfiles\wezterm\wezterm.lua
```

`wsl -l -v` の distro 名が `NixOS` と異なる場合は、上記コマンドのパスと
`wezterm/wezterm.lua` 内の `distro` 変数を実際の名前に合わせて書き換える。

## AutoHotkey の設定

WezTerm には Windows Terminal の Quake モードのような表示/非表示トグルが無く、
`wezterm.lua` 側のキーバインドは WezTerm フォーカス時にしか効かない(隠れている
状態からは呼び出せない)。そのため Windows 側で AutoHotkey v2 を使い、
`autohotkey/wezterm-toggle.ahk` でフォーカス状態に関係ないグローバルホットキー
を提供する。

- `Ctrl+Alt+Up` … WezTerm を前面に呼び出す(最小化していれば復元)
- `Ctrl+Alt+Down` … WezTerm を最小化して背面に隠す

セットアップ:

1. Windows に [AutoHotkey v2](https://www.autohotkey.com/) をインストールする。
2. `autohotkey/wezterm-toggle.ahk` を実行する。ログイン時に自動起動させたい
   場合はスタートアップフォルダにショートカット(または PowerShell でシンボリック
   リンク)を作成する。

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
