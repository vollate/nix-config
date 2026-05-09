{ ... }:

{
  home.sessionVariables = {
    PNPM_HOME = "$HOME/.local/share/pnpm";
  };

  home.sessionPath = [
    "$PNPM_HOME"
  ];
}
