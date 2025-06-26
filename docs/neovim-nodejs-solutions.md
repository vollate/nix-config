# Neovim + Node.js 解决方案

当使用 coc-nvim 时，需要 Node.js 环境，但不是所有机器都需要完整的开发环境。以下是几种解决方案：

## 方案1: 使用 Overlay (推荐)

通过 overlay 创建一个包含 Node.js 的 Neovim 包：

### 1. Overlay 定义

```nix
# overlays/neovim-with-nodejs.nix
final: prev: {
  neovim-with-nodejs = prev.symlinkJoin {
    name = "neovim-with-nodejs";
    paths = with prev; [
      neovim
      nodejs
      npm
    ];
    
    buildInputs = with prev; [ makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/nvim \
        --prefix PATH : ${prev.lib.makeBinPath [ prev.nodejs prev.npm ]}
    '';
  };
}
```

### 2. 在 flake.nix 中应用

```nix
# flake.nix
nixosConfigurations = {
  my-host = myLib.mkHost {
    hostname = "my-host";
    username = "user";
    overlays = overlays; # 应用 overlays
  };
};
```

### 3. 在 Home Manager 中使用

```nix
# home/user/programs/neovim.nix
home.packages = with pkgs; [
  neovim-with-nodejs  # 使用带 Node.js 的版本
  ripgrep
  fd
];
```

## 方案2: 系统模块配置

创建一个可配置的 Neovim 模块：

### 使用方式

```nix
# 在主机配置中
programs.neovim-custom = {
  enable = true;
  withNodejs = true;  # 根据需要启用/禁用
  extraPackages = with pkgs; [
    # 其他需要的包
  ];
};
```

### 不同场景的配置

#### 开发机器 (完整环境)
```nix
# hosts/dev-machine/default.nix
{
  imports = [
    ../../modules/development  # 包含完整开发环境
  ];
  
  programs.neovim-custom = {
    enable = true;
    withNodejs = false;  # 开发环境已包含 Node.js
  };
}
```

#### 服务器/简单机器 (只需要编辑器)
```nix
# hosts/server/default.nix
{
  programs.neovim-custom = {
    enable = true;
    withNodejs = true;   # 只为 Neovim 提供 Node.js
  };
}
```

## 方案3: 条件导入

在 neovim.nix 中根据系统配置动态决定：

```nix
# home/user/programs/neovim.nix
{ config, lib, pkgs, ... }:

let
  # 检查是否已经有开发环境
  hasDevEnv = config.programs ? development || 
              builtins.elem pkgs.nodejs config.environment.systemPackages;
  
  neovimPackages = with pkgs; [
    neovim
    ripgrep
    fd
  ] ++ lib.optionals (!hasDevEnv) [
    nodejs  # 只在没有开发环境时添加
    npm
  ];
in
{
  home.packages = neovimPackages;
}
```

## 推荐配置

### 对于大多数用户 (方案1)
```nix
# 使用 overlay，简单直接
nixosConfigurations.my-host = myLib.mkHost {
  hostname = "my-host";
  username = "user";
  overlays = overlays;
};

# home/user/programs/neovim.nix
home.packages = with pkgs; [
  neovim-with-nodejs
  ripgrep
  fd
];
```

### 对于多机器管理 (方案2)
```nix
# 使用模块，更灵活的配置
programs.neovim-custom = {
  enable = true;
  withNodejs = true;  # 根据机器需求调整
};
```

## 优势对比

| 方案 | 优势 | 适用场景 |
|------|------|----------|
| Overlay | 简单、干净、版本统一 | 单一用户、简单配置 |
| 系统模块 | 灵活、可配置、复用性强 | 多机器、团队使用 |
| 条件导入 | 智能、避免冲突 | 复杂环境、自动化 |

## 性能和冲突考虑

1. **避免重复**: 确保 Node.js 只安装一次
2. **版本一致**: 使用相同的 nixpkgs 确保版本统一
3. **路径优先级**: overlay 方案通过 wrapper 确保正确的 PATH

选择最适合您使用场景的方案即可！ 