{ ... }:

{
  # Windows 側の powershell.exe / pwsh.exe / cmd.exe を WSL からそのまま
  # 呼べるようにする。WSL 上のパスを引数に渡してもそのままでは Windows
  # 側が解釈できないため、実在するパスは自動で wslpath -w 変換してから渡す。
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

    # 既定の実行ポリシー(Restricted)だとスクリプト実行がブロックされる
    # ことがあるため、この呼び出しに限り Bypass にする(システム全体の
    # ポリシーは変更しない)。
    function powershell --description 'Run Windows powershell.exe (Windows PowerShell 5.1)'
      powershell.exe -ExecutionPolicy Bypass (__win_args $argv)
    end

    function pwsh --description 'Run Windows pwsh.exe (PowerShell 7+)'
      pwsh.exe -ExecutionPolicy Bypass (__win_args $argv)
    end

    # .cmd/.bat は PE バイナリではないため WSL の binfmt 連携では直接実行
    # できない。cmd.exe /c 経由で実行する。
    function cmd --description 'Run a Windows .cmd/.bat script via cmd.exe /c'
      cmd.exe /c (__win_args $argv)
    end
  '';
}
