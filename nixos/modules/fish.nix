{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    fzf
    fishPlugins.fzf-fish
    fishPlugins.tide
  ];

  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      set -g fish_greeting

      if not set -q tide_setup_done
        tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Dotted --prompt_connection_andor_frame_color=Dark --prompt_spacing=Compact --icons='Many icons' --transient=No
        set -U tide_setup_done true
      end
    '';
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
