# Neovim with Node.js overlay
# Add Node.js dependencies for Neovim to ensure coc-nvim works properly

final: prev: {
  # Create a Neovim package with Node.js included
  neovim-with-nodejs = prev.symlinkJoin {
    name = "neovim-with-nodejs";
    paths = with prev; [ neovim nodejs nodePackages.pnpm ];

    # Set environment variables to ensure coc-nvim can find Node.js
    buildInputs = with prev; [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nvim \
        --prefix PATH : ${
          prev.lib.makeBinPath [ prev.nodejs prev.nodePackages.pnpm ]
        }
    '';

    meta = prev.neovim.meta // {
      description = "Neovim with Node.js and pnpm for coc-nvim support";
    };
  };

  # Alternatively, you can directly override the neovim package
  # neovim = prev.neovim.overrideAttrs (oldAttrs: {
  #   buildInputs = (oldAttrs.buildInputs or []) ++ [ prev.nodejs prev.nodePackages.pnpm ];
  # });
}
