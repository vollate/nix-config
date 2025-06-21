# Neovim with Node.js overlay
# 为 Neovim 添加 Node.js 依赖，确保 coc-nvim 可以正常工作

final: prev: {
  # 创建一个包含 Node.js 的 Neovim 包
  neovim-with-nodejs = prev.symlinkJoin {
    name = "neovim-with-nodejs";
    paths = with prev; [
      neovim
      nodejs
      npm
    ];
    
    # 设置环境变量确保 coc-nvim 能找到 Node.js
    buildInputs = with prev; [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nvim \
        --prefix PATH : ${prev.lib.makeBinPath [ prev.nodejs prev.npm ]}
    '';
    
    meta = prev.neovim.meta // {
      description = "Neovim with Node.js for coc-nvim support";
    };
  };
  
  # 也可以直接覆盖 neovim 包
  # neovim = prev.neovim.overrideAttrs (oldAttrs: {
  #   buildInputs = (oldAttrs.buildInputs or []) ++ [ prev.nodejs prev.npm ];
  # });
} 