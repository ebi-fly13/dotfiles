{ lib, ... }:

let
  winExeCommands = [
    "op" # 1Password CLI
  ];

  winExeFunctions = lib.concatMapStrings (name: ''
    function ${name} --description 'Run Windows ${name}.exe'
      ${name}.exe (__win_args $argv)
    end

  '') winExeCommands;
in

{
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

    # この呼び出しに限り実行ポリシーを Bypass にする(システム全体には影響しない)。
    function powershell --description 'Run Windows powershell.exe (Windows PowerShell 5.1)'
      powershell.exe -ExecutionPolicy Bypass (__win_args $argv)
    end

    function pwsh --description 'Run Windows pwsh.exe (PowerShell 7+)'
      pwsh.exe -ExecutionPolicy Bypass (__win_args $argv)
    end

    function cmd --description 'Run a Windows .cmd/.bat script via cmd.exe /c'
      cmd.exe /c (__win_args $argv)
    end

    ${winExeFunctions}
    # /mnt 配下は 9p 経由の Linux git が遅いため git.exe を使う。
    function git --description 'Use Windows git.exe under /mnt, otherwise the native git'
      if string match -q '/mnt/*' -- $PWD; and command -sq git.exe
        git.exe $argv
      else
        command git $argv
      end
    end
  '';
}
