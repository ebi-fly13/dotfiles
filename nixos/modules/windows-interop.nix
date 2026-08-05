{ lib, pkgs, wslwrap-fish, ... }:

let
  # https://github.com/drop-stones/wslwrap.fish
  # /mnt 配下では Windows 版 exe、それ以外では Linux 版バイナリを自動選択する
  # fish プラグイン。bare なコマンド名(拡張子なし)から .exe を解決してくれる。
  wslwrapFish = pkgs.fishPlugins.buildFishPlugin {
    pname = "wslwrap-fish";
    version = "unstable";
    src = wslwrap-fish;
    meta = {
      description = "Switches between Linux and Windows executables inside WSL2";
      homepage = "https://github.com/drop-stones/wslwrap.fish";
      license = lib.licenses.mit;
    };
  };
in

{
  environment.systemPackages = [ wslwrapFish ];

  # wslwrap-aware `which`。素の which/command -v は fish 関数(register で
  # 登録したラッパーなど)を解決できないため、wslwrap 側の解決結果を返す
  # `wslwrap which` に差し替える。
  programs.fish.shellAliases = {
    which = "wslwrap which";
  };

  programs.fish.shellInit = ''
    function __win_args --description 'Convert existing WSL file paths in $argv to Windows paths'
      for arg in $argv
        if test -e "$arg"
          wslpath -w "$arg"
        else
          printf '%s\n' $arg
        end
      end
    end

    # 1Password CLI。Linux 版は未導入のため常に Windows 版を使う。
    wslwrap register --mode windows op

    # この呼び出しに限り実行ポリシーを Bypass にする(システム全体には影響しない)。
    wslwrap register --mode windows powershell -ExecutionPolicy Bypass
    wslwrap register --mode windows pwsh -ExecutionPolicy Bypass
    # cmd.exe /c 経由でスクリプトを実行する。
    wslwrap register --mode windows cmd /c

    # /mnt 配下は 9p 経由の Linux git が遅いため git.exe を使う。それ以外では
    # Linux 版 git を使う(wslwrap の auto モード)。cwd に応じた切り替えが
    # 必要なため link ではなく register(auto モード)を使う。
    wslwrap register git

    # register は fish 関数なので fish 経由の呼び出ししか解決できない。
    # 非 fish プロセスからも exec できるよう link で $PATH に実体を置く。
    wslwrap link cmd
    wslwrap link powershell

    # code コマンドは WSL 内から呼ぶと常に Remote-WSL 拡張機能経由で開こうとするため、
    # /mnt 配下の Windows 側ファイルを開くときはネイティブの Code.exe を直接起動する。
    function code --description 'Use native Windows Code.exe under /mnt, otherwise the WSL code'
      if string match -q '/mnt/*' -- $PWD
        set -l wsl_code (command -s code)
        set -l vscode_dir (dirname (dirname (realpath $wsl_code)))
        "$vscode_dir/Code.exe" (__win_args $argv) &
        disown
      else
        command code $argv
      end
    end
  '';
}
