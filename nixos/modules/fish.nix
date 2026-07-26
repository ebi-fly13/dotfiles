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

      # tide renders its two-line prompt in a background `fish -c`
      # subprocess that skips normal interactive init, so a merely
      # global $fish_key_bindings never reaches it there and tide's
      # character segment falls back to its vi-normal-mode icon (a
      # left-pointing "<") instead of the intended ">". Universal
      # variables are visible in that subprocess too, so use one.
      if test "$fish_key_bindings" != fish_default_key_bindings
        set -U fish_key_bindings fish_default_key_bindings
      end

      if not set -q tide_setup_done
        tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Dotted --prompt_connection_andor_frame_color=Dark --prompt_spacing=Compact --icons='Few icons' --transient=No
        set -U tide_setup_done true
      end
    '';
  };

  programs.zoxide = {
    enable = true;
    enableFishIntegration = true;
  };
}
