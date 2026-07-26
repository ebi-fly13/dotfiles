{ pkgs, ... }:

{
  # WezTerm (Windows 側) から接続すると TERM=wezterm が渡ってくる。
  # このデータベースが無いと vim/less/top など画面制御アプリで
  # 表示が崩れたり "unknown terminal type" になる。
  environment.systemPackages = [
    pkgs.wezterm.terminfo
  ];
}
