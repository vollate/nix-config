{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.tmux = {
    enable = true;
    mouse = true;
    keyMode = "vi";
    terminal = "screen-256color";
    plugins = with pkgs.tmuxPlugins; [
      sensible
      yank
      prefix-highlight
      {
        plugin = power-theme;
        extraConfig = ''
          set -g @tmux_power_theme 'snow'
          set -g @tmux_power_date_icon ' '
          set -g @tmux_power_time_icon ' '
          set -g @tmux_power_user_icon ' '
          set -g @tmux_power_session_icon ' '
          set -g @tmux_power_right_arrow_icon     ''
          set -g @tmux_power_left_arrow_icon      ''
          set -g @tmux_power_prefix_highlight_pos 'R'
        '';
      }
    ];
    extraConfig = ''
      set -g prefix2 C-a
      bind C-a send-prefix -2

      bind s split-window -v
      bind v split-window -h

      set -g @yank_with_mouse on
      set -g @prefix_highlight_show_copy_mode on
      set -g @prefix_highlight_show_sync_mode on
      set -g @prefix_highlight_prefix_prompt '  '
      set -g @prefix_highlight_copy_prompt '  '
      set -g @prefix_highlight_sync_prompt ' 󰓦 '
    '';
  };
}
