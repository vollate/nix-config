# 📦 NixOS 应用安装位置指南

在模块化的 NixOS 配置中，安装应用的位置取决于应用的类型和使用场景。本指南将详细说明各种场景下的最佳实践。

## 🎯 安装位置决策流程图

```
需要安装应用？
├── 所有用户都需要？
│   ├── 是 → 系统级安装
│   │   ├── 桌面应用 → modules/desktop/default.nix
│   │   ├── 开发工具 → modules/development/default.nix
│   │   └── 主机特定 → hosts/hostname/default.nix
│   └── 否 → 用户级安装
│       ├── 需要复杂配置？
│       │   ├── 是 → home/user/programs/app.nix
│       │   └── 否 → home/user/default.nix 或 home/user/desktop/default.nix
```

## 1. 系统级安装 (所有用户可用)

### 🖥️ 桌面应用 → `modules/desktop/default.nix`

用于安装桌面环境相关的应用程序，如浏览器、媒体播放器、办公软件等。

```nix
# modules/desktop/default.nix
environment.systemPackages = with pkgs; [
  # 现有应用
  firefox
  chromium
  vlc
  gimp
  libreoffice
  telegram-desktop
  discord
  
  # 添加新的桌面应用
  spotify          # 音乐播放器
  obs-studio       # 录屏软件
  krita           # 数字绘画
  thunderbird     # 邮件客户端
  zoom-us         # 视频会议
  blender         # 3D建模
];
```

**适用场景**：
- 图形界面应用
- 多媒体软件
- 办公软件
- 通讯软件

### 🛠️ 开发工具 → `modules/development/default.nix`

用于安装开发相关的工具和软件。

```nix
# modules/development/default.nix
environment.systemPackages = with pkgs; [
  # 现有开发工具
  git
  neovim
  vscode
  
  # 添加新的开发工具
  postman         # API 测试工具
  dbeaver         # 数据库管理
  insomnia        # REST 客户端
  wireshark       # 网络分析
  docker-compose  # 容器编排
  kubectl         # Kubernetes 客户端
  terraform       # 基础设施即代码
];
```

**适用场景**：
- 代码编辑器和IDE
- 版本控制工具
- 数据库工具
- API测试工具
- 容器和云工具

### 🏠 主机特定应用 → `hosts/tb-amd-6800h/default.nix`

用于安装只有特定主机需要的应用。

```nix
# hosts/tb-amd-6800h/default.nix
environment.systemPackages = with pkgs; [
  # 主机特定应用
  nvidia-settings  # NVIDIA显卡设置 (如果有N卡)
  steam           # 游戏平台 (如果这台机器用来游戏)
  wine            # Windows兼容层
  lutris          # 游戏管理器
  
  # 硬件相关工具
  lm_sensors      # 硬件监控
  smartmontools   # 硬盘健康监控
  stress          # 压力测试
];
```

**适用场景**：
- 硬件特定工具
- 游戏软件
- 特殊用途软件
- 主机独有需求

## 2. 用户级安装 (只有特定用户可用)

### 🏠 用户通用应用 → `home/vollate/default.nix`

用于安装用户常用但不需要复杂配置的应用。

```nix
# home/vollate/default.nix
home.packages = with pkgs; [
  # 现有CLI工具
  ripgrep
  fd
  bat
  fzf
  
  # 添加新的用户应用
  discord         # 聊天软件
  telegram-desktop # 即时通讯
  obsidian        # 笔记软件
  notion-app-enhanced # 笔记和协作
  spotify         # 音乐 (用户级)
  
  # CLI工具
  htop            # 系统监控
  tree            # 目录树显示
  jq              # JSON处理
  curl            # 网络工具
  wget            # 下载工具
];
```

### 🖥️ 用户桌面应用 → `home/vollate/desktop/default.nix`

用于安装桌面相关的用户应用。

```nix
# home/vollate/desktop/default.nix
home.packages = with pkgs; [
  # 现有桌面应用
  dolphin
  vlc
  gwenview
  
  # 添加新的桌面应用
  krita           # 绘画软件
  blender         # 3D建模
  thunderbird     # 邮件客户端
  calibre         # 电子书管理
  flameshot       # 截图工具
  
  # 文件管理
  ark             # 解压缩工具
  filelight       # 磁盘使用分析
];
```

### ⚙️ 带配置的程序 → `home/vollate/programs/`

对于需要复杂配置的应用，应该创建专门的配置文件。

#### Firefox 配置示例

```nix
# home/vollate/programs/firefox.nix
{ config, lib, pkgs, ... }:

{
  programs.firefox = {
    enable = true;
    
    profiles.default = {
      name = "Default";
      isDefault = true;
      
      settings = {
        # 隐私设置
        "privacy.trackingprotection.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "privacy.trackingprotection.socialtracking.enabled" = true;
        
        # 性能优化
        "browser.sessionstore.interval" = 15000;
        
        # UI 自定义
        "browser.tabs.warnOnClose" = false;
        "browser.shell.checkDefaultBrowser" = false;
      };
      
      # 扩展插件
      extensions = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        bitwarden
        privacy-badger
        darkreader
      ];
    };
  };
}
```

#### VS Code 配置示例

```nix
# home/vollate/programs/vscode.nix
{ config, lib, pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    
    extensions = with pkgs.vscode-extensions; [
      # 语言支持
      ms-python.python
      rust-lang.rust-analyzer
      bradlc.vscode-tailwindcss
      ms-vscode.cpptools
      
      # 主题
      catppuccin.catppuccin-vsc
      pkief.material-icon-theme
      
      # 实用工具
      eamodio.gitlens
      esbenp.prettier-vscode
      ms-vscode.hexdump
      formulahendry.auto-rename-tag
    ];
    
    userSettings = {
      "workbench.colorTheme" = "Catppuccin Mocha";
      "workbench.iconTheme" = "material-icon-theme";
      "editor.fontFamily" = "'JetBrains Mono', 'Droid Sans Mono', monospace";
      "editor.fontSize" = 14;
      "editor.tabSize" = 2;
      "editor.insertSpaces" = true;
      "files.autoSave" = "afterDelay";
      "git.enableSmartCommit" = true;
      "python.defaultInterpreterPath" = "python3";
      "terminal.integrated.fontSize" = 13;
    };
  };
}
```

#### Neovim 配置示例

对于 Neovim，有两种主要的配置方式：

**方式1: 使用 Home Manager 管理 ~/.config/nvim 目录（推荐）**

```nix
# home/vollate/programs/neovim.nix
{ config, lib, pkgs, ... }:

{
  # 只安装 neovim 和基础工具
  home.packages = with pkgs; [
    neovim
    
    # 基础工具
    ripgrep # telescope/搜索需要
    fd # 文件查找需要
  ];

  # 管理 nvim 配置文件
  xdg.configFile = {
    "nvim" = {
      source = ./nvim-config;
      recursive = true;
    };
  };
  
  # 设置为默认编辑器
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
  
  # 注意: 如果使用 coc-nvim，Node.js 通过开发环境模块安装
  # LSP servers 可以通过 coc 扩展自动管理
}
```

然后在 `home/vollate/programs/nvim-config/` 目录下放置您的 Neovim 配置：

```
home/vollate/programs/nvim-config/
├── init.lua                 # 主配置文件
├── lua/
│   ├── config/
│   │   ├── options.lua      # 基础选项
│   │   ├── keymaps.lua      # 快捷键
│   │   └── autocmds.lua     # 自动命令
│   └── plugins/
│       ├── init.lua         # 插件管理器
│       ├── lsp.lua          # LSP 配置
│       ├── treesitter.lua   # 语法高亮
│       └── telescope.lua    # 模糊搜索
└── after/
    └── plugin/
```

**方式2: 使用 Home Manager 的 programs.neovim（简单配置）**

```nix
# home/vollate/programs/neovim.nix
{ config, lib, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    
    # 仅用于简单配置，复杂配置建议使用方式1
    extraConfig = ''
      lua << EOF
      -- 基础设置
      vim.opt.number = true
      vim.opt.relativenumber = true
      vim.opt.expandtab = true
      vim.opt.tabstop = 2
      vim.opt.shiftwidth = 2
      vim.opt.smartindent = true
      EOF
    '';
    
    # 仅安装必要插件，复杂配置用 Lazy.nvim 等插件管理器
    plugins = with pkgs.vimPlugins; [
      # 基础插件
      nvim-treesitter.withAllGrammars
      telescope-nvim
      nvim-lspconfig
    ];
  };
}
```

**推荐使用方式1**，因为：
- 符合 Neovim 社区的常见做法
- 可以直接使用现有的 Neovim 配置
- 支持复杂的插件管理器（如 Lazy.nvim, Packer）
- 更容易与他人分享配置

然后在 `home/vollate/programs/default.nix` 中导入：

```nix
# home/vollate/programs/default.nix
{ config, lib, pkgs, ... }:

{
  imports = [
    ./neovim.nix
    ./firefox.nix
    ./vscode.nix
    ./git.nix
  ];
}
```

## 💡 具体应用示例

### 示例1: 安装 Discord (简单用户应用)

```nix
# 选择: home/vollate/default.nix
home.packages = with pkgs; [
  # ... 现有包 ...
  discord
];
```

### 示例2: 安装 OBS Studio (需要系统权限)

```nix
# 选择: modules/desktop/default.nix
environment.systemPackages = with pkgs; [
  # ... 现有包 ...
  obs-studio
];
```

### 示例3: 安装 Steam (主机特定)

```nix
# 选择: hosts/tb-amd-6800h/default.nix
environment.systemPackages = with pkgs; [
  # ... 现有包 ...
  steam
];

# 还需要启用Steam支持
programs.steam = {
  enable = true;
  remotePlay.openFirewall = true;
  dedicatedServer.openFirewall = true;
};
```

### 示例4: 安装开发数据库工具

```nix
# 选择: modules/development/default.nix
environment.systemPackages = with pkgs; [
  # ... 现有包 ...
  dbeaver
  pgadmin4
  mongodb-compass
];
```

### 示例5: 安装 GnuPG (加密工具)

```nix
# 系统级安装 - modules/base/default.nix
environment.systemPackages = with pkgs; [
  # ... 现有包 ...
  gnupg
];

# GPG Agent 配置 - modules/base/security.nix
programs.gnupg.agent = {
  enable = true;
  enableSSHSupport = true;
  pinentryPackage = pkgs.pinentry-curses;
};

# 用户级配置 - home/vollate/programs/gpg.nix
programs.gpg = {
  enable = true;
  settings = {
    # 现代安全设置
    personal-cipher-preferences = "AES256 AES192 AES";
    personal-digest-preferences = "SHA512 SHA384 SHA256";
    cert-digest-algo = "SHA512";
    # ... 更多配置 ...
  };
};

services.gpg-agent = {
  enable = true;
  enableSshSupport = true;
  enableZshIntegration = true;
  defaultCacheTtl = 1800;
  maxCacheTtl = 7200;
};
```

## 🔄 应用生效方法

### 重建配置

安装应用后，需要重建配置使其生效：

```bash
# 系统级应用（推荐）
sudo nixos-rebuild switch --flake .

# 或使用 Justfile
just deploy

# 仅用户级应用（如果单独管理 Home Manager）
home-manager switch --flake .
```

### 检查配置

```bash
# 检查配置是否正确
just check

# 或手动检查
nix flake check
nixos-rebuild dry-build --flake .
```

## 📝 最佳实践

### 1. 选择原则

- **优先用户级安装**: 除非需要系统服务或所有用户共享
- **按功能分类**: 桌面应用、开发工具、系统工具分开放置
- **主机特定**: 只有特定硬件或用途的应用放在主机配置中

### 2. 配置管理

- **简单应用**: 直接添加到包列表
- **复杂配置**: 创建专门的配置文件
- **版本管理**: 使用Git跟踪所有配置变更

### 3. 测试和部署

- **先测试**: 使用 `just check` 验证配置
- **增量部署**: 一次添加少量应用，逐步验证
- **备份回滚**: 保留旧的系统代数以便快速回滚

### 4. 文档维护

- **记录变更**: 在Git提交信息中说明添加的应用
- **更新文档**: 及时更新README和相关文档
- **分享经验**: 记录特殊配置和解决方案

## 🔍 常见问题

### Q: 应用安装后找不到？

A: 检查以下几点：
1. 确认配置已重建生效
2. 对于GUI应用，可能需要重新登录
3. 检查应用是否需要额外的系统服务

### Q: 应用版本太旧？

A: 可以尝试：
1. 使用 `nixpkgs-unstable` 分支
2. 使用 overlay 覆盖包版本
3. 从其他源安装（如 Flatpak）

### Q: 配置冲突怎么办？

A: 解决方法：
1. 使用 `lib.mkForce` 强制覆盖
2. 检查模块导入顺序
3. 使用条件判断避免冲突

---

> 💡 **提示**: 这个指南会随着配置的完善而更新。建议根据实际使用情况调整和优化。 