{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    mouse = true;
    keyMode = "vi";
    terminal = "screen-256color";
    # Load sensible before our limits; it otherwise raises the default history limit.
    sensibleOnTop = true;
    historyLimit = 20000;
    plugins = with pkgs.tmuxPlugins; [
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
      # Limits are per pane / automatic paste buffer, not a server-wide RAM cap.
      set -s buffer-limit 10
      set -s input-buffer-size 1048576
      # Still allow copying out, but do not accept application-created OSC 52 buffers.
      set -s set-clipboard external

      set -g renumber-windows on

      set -g prefix2 C-a
      bind C-a send-prefix -2

      bind s split-window -v -c '#{pane_current_path}'
      bind v split-window -h -c '#{pane_current_path}'

      set -g @yank_with_mouse on
      set -g @prefix_highlight_show_copy_mode on
      set -g @prefix_highlight_show_sync_mode on
      set -g @prefix_highlight_prefix_prompt '  '
      set -g @prefix_highlight_copy_prompt '  '
      set -g @prefix_highlight_sync_prompt ' 󰓦 '
    '';
  };
}
