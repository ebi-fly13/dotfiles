{ lib, personalConfigPath, ... }:

lib.mkIf (personalConfigPath != null) {
  # private repo 側に置いた fish ファイルを読み込む。
  programs.fish.shellInit = ''
    if test -r ${personalConfigPath}/fish/env.fish
      source ${personalConfigPath}/fish/env.fish
    end
  '';
}
