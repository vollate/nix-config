# ❄️ Vollate's NixOS Configuration

> 基于 [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config) 的模块化 NixOS 配置

这是一个模块化的 NixOS Flake 配置，采用了清晰的目录结构和合理的模块分离，便于维护和扩展。

## 📁 目录结构

```
nix-config/
├── flake.nix                 # 主 Flake 配置文件
├── flake.lock               # Flake 锁定文件
├── README.md                # 说明文档
├── LICENSE                  # 许可证
│
├── lib/                     # 自定义库函数
│   └── default.nix         # 包含 mkSystem, mkHost 等辅助函数
│
├── modules/                 # 系统模块
│   ├── base/               # 基础系统配置
│   │   ├── default.nix     # 基础模块入口
│   │   ├── boot.nix        # 启动配置
│   │   ├── network.nix     # 网络配置
│   │   ├── locale.nix      # 本地化配置
│   │   ├── users.nix       # 用户管理
│   │   ├── nix.nix         # Nix 配置
│   │   └── security.nix    # 安全配置
│   │
│   ├── desktop/            # 桌面环境模块
│   │   ├── default.nix     # 桌面模块入口 
│   │   ├── audio.nix       # 音频配置 (PipeWire)
│   │   ├── fonts.nix       # 字体配置
│   │   ├── xserver.nix     # X11 配置
│   │   └── plasma.nix      # KDE Plasma 配置
│   │
│   └── development/        # 开发环境模块
│       ├── default.nix     # 开发模块入口
│       ├── programming.nix # 编程语言和工具
│       ├── docker.nix      # Docker 配置
│       └── virtualisation.nix # 虚拟化配置
│
├── hosts/                   # 主机特定配置
│   └── tb-amd-6800h/       # 主机名称
│       ├── default.nix     # 主机主配置
│       ├── hardware-configuration.nix # 硬件配置 (自动生成)
│       ├── networking.nix  # 主机网络配置
│       └── hardware.nix    # 主机硬件优化
│
├── home/                    # Home Manager 配置
│   └── vollate/            # 用户名称
│       ├── default.nix     # Home Manager 入口
│       ├── programs/       # 程序配置
│       │   ├── default.nix # 程序模块入口
│       │   ├── neovim.nix  # Neovim 配置
│       │   ├── firefox.nix # Firefox 配置
│       │   └── vscode.nix  # VS Code 配置
│       ├── shell/          # Shell 配置  
│       │   ├── default.nix # Shell 模块入口
│       │   ├── zsh.nix     # Zsh 配置
│       │   ├── git.nix     # Git 配置
│       │   └── starship.nix # Starship 提示符配置
│       └── desktop/        # 桌面用户配置
│           ├── default.nix # 桌面模块入口
│           ├── gtk.nix     # GTK 主题配置
│           └── fonts.nix   # 字体配置
│
└── users/                   # 用户系统配置
    └── vollate.nix         # 用户系统级配置
```

## 🔄 配置层次和包含逻辑

### 1. Flake 入口 (`flake.nix`)
```nix
# 导入自定义库
myLib = import ./lib { inherit (nixpkgs) lib; inherit inputs; };

# 使用库函数创建系统配置
nixosConfigurations.tb-amd-6800h = myLib.mkHost {
  hostname = "tb-amd-6800h";
  username = "vollate";
  desktop = "plasma";
};
```

### 2. 库函数层 (`lib/default.nix`)
```nix
# mkHost 函数自动包含标准模块
mkHost = args: mkSystem (args // {
  modules = [
    ../modules/base      # 基础系统
    ../modules/desktop   # 桌面环境  
    ../modules/development # 开发环境
  ] ++ (args.modules or []);
});
```

### 3. 模块层 (`modules/`)
每个模块都有自己的职责：
- **base/**: 系统基础设施（启动、网络、用户等）
- **desktop/**: 桌面环境相关（音频、字体、显示器等）
- **development/**: 开发工具和环境

### 4. 主机层 (`hosts/`)
```nix
# 主机配置导入主机特定模块
imports = [
  ./hardware-configuration.nix  # 硬件扫描结果
  ./networking.nix              # 主机网络配置
  ./hardware.nix                # 主机硬件优化
];
```

### 5. Home Manager 层 (`home/`)
```nix
# 用户级配置，管理用户程序和设置
imports = [
  ./programs    # 程序配置
  ./shell       # Shell 环境
  ./desktop     # 桌面用户配置
];
```

## 🚀 部署方式

### 初次部署
```bash
# 克隆配置
git clone <your-repo> ~/.config/nix-config
cd ~/.config/nix-config

# 部署系统配置
sudo nixos-rebuild switch --flake .#tb-amd-6800h
```

### 日常更新
```bash
# 切换配置
sudo nixos-rebuild switch --flake .

# 更新系统
sudo nixos-rebuild switch --upgrade --flake .

# 清理旧代
sudo nix-collect-garbage -d
```

### 开发环境
```bash
# 进入开发环境 (包含 nil, nixfmt 等工具)
nix develop

# 格式化 Nix 代码
nix fmt
```

## 🎨 特色功能

### 🖥️ 桌面环境
- **KDE Plasma 6**: 现代化的桌面环境
- **PipeWire**: 统一的音频解决方案
- **中文输入法**: Fcitx5 + Rime
- **字体配置**: Nerd Fonts + 中文字体支持

### 🛠️ 开发环境
- **多语言支持**: Python, Node.js, Rust, Go, Java, Haskell
- **容器化**: Docker + Podman
- **虚拟化**: KVM/QEMU + libvirt
- **编辑器**: Neovim + VS Code

### 🏠 Home Manager
- **Shell**: Zsh + Oh My Zsh + Starship
- **终端工具**: ripgrep, fd, bat, exa, fzf
- **Git 配置**: 完整的 Git 工作流配置
- **程序配置**: 统一管理所有用户程序

## 🔧 自定义配置

### 添加新主机
1. 在 `hosts/` 目录创建新主机文件夹
2. 复制 `hardware-configuration.nix`
3. 在 `flake.nix` 中添加新配置：
```nix
nixosConfigurations.new-host = myLib.mkHost {
  hostname = "new-host";
  username = "vollate";
  desktop = "plasma"; # 或其他桌面环境
};
```

### 添加新桌面环境
1. 在 `modules/desktop/` 创建新桌面模块
2. 在 `modules/desktop/default.nix` 中添加条件导入
3. 使用时指定 `desktop` 参数

### 自定义 Home Manager
修改 `home/vollate/` 下的相应文件：
- `programs/`: 添加新程序配置
- `shell/`: 修改 Shell 设置  
- `desktop/`: 调整桌面用户配置

## 📚 参考资源

- [NixOS & Nix Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)

## 📝 许可证

MIT License - 详见 [LICENSE](LICENSE) 文件

---

> 💡 **提示**: 这个配置专为学习和参考设计。请根据你的硬件和需求进行相应调整。 