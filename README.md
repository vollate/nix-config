# ❄️ Vollate's NixOS Configuration

> Modular NixOS configuration based on [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)

This is a modular NixOS Flake configuration with a clean directory structure and reasonable module separation, making it easy to maintain and extend.

## 📁 Directory Structure

```
nix-config/
├── flake.nix                 # Main Flake configuration file
├── flake.lock               # Flake lock file
├── README.md                # Documentation
├── LICENSE                  # License
│
├── lib/                     # Custom library functions
│   └── default.nix         # Contains helper functions like mkSystem, mkHost
│
├── modules/                 # System modules
│   ├── base/               # Basic system configuration
│   │   ├── default.nix     # Base module entry point
│   │   ├── boot.nix        # Boot configuration
│   │   ├── network.nix     # Network configuration
│   │   ├── locale.nix      # Localization configuration
│   │   ├── users.nix       # User management
│   │   ├── nix.nix         # Nix configuration
│   │   └── security.nix    # Security configuration
│   │
│   ├── desktop/            # Desktop environment modules
│   │   ├── default.nix     # Desktop module entry point
│   │   ├── audio.nix       # Audio configuration (PipeWire)
│   │   ├── fonts.nix       # Font configuration
│   │   ├── xserver.nix     # X11 configuration
│   │   └── plasma.nix      # KDE Plasma configuration
│   │
│   └── development/        # Development environment modules
│       ├── default.nix     # Development module entry point
│       ├── programming.nix # Programming languages and tools
│       ├── docker.nix      # Docker configuration
│       └── virtualisation.nix # Virtualization configuration
│
├── hosts/                   # Host-specific configurations
│   └── tb-amd-6800h/       # Hostname
│       ├── default.nix     # Host main configuration
│       ├── hardware-configuration.nix # Hardware configuration (auto-generated)
│       ├── networking.nix  # Host network configuration
│       └── hardware.nix    # Host hardware optimization
│
├── home/                    # Home Manager configuration
│   └── vollate/            # Username
│       ├── default.nix     # Home Manager entry point
│       ├── programs/       # Program configurations
│       │   ├── default.nix # Program module entry point
│       │   ├── neovim.nix  # Neovim configuration
│       │   ├── firefox.nix # Firefox configuration
│       │   └── vscode.nix  # VS Code configuration
│       ├── shell/          # Shell configuration
│       │   ├── default.nix # Shell module entry point
│       │   ├── zsh.nix     # Zsh configuration
│       │   ├── git.nix     # Git configuration
│       │   └── starship.nix # Starship prompt configuration
│       └── desktop/        # Desktop user configuration
│           ├── default.nix # Desktop module entry point
│           ├── gtk.nix     # GTK theme configuration
│           └── fonts.nix   # Font configuration
│
└── users/                   # User system configuration
    └── vollate.nix         # User system-level configuration
```

## 🔄 Configuration Hierarchy and Inclusion Logic

### 1. Flake Entry Point (`flake.nix`)
```nix
# Import custom library
myLib = import ./lib { inherit (nixpkgs) lib; inherit inputs; };

# Use library functions to create system configuration
nixosConfigurations.tb-amd-6800h = myLib.mkHost {
  hostname = "tb-amd-6800h";
  username = "vollate";
  desktop = "plasma";
};
```

### 2. Library Function Layer (`lib/default.nix`)
```nix
# mkHost function automatically includes standard modules
mkHost = args: mkSystem (args // {
  modules = [
    ../modules/base      # Basic system
    ../modules/desktop   # Desktop environment
    ../modules/development # Development environment
  ] ++ (args.modules or []);
});
```

### 3. Module Layer (`modules/`)
Each module has its own responsibility:
- **base/**: System infrastructure (boot, network, users, etc.)
- **desktop/**: Desktop environment related (audio, fonts, display, etc.)
- **development/**: Development tools and environments

### 4. Host Layer (`hosts/`)
```nix
# Host configuration imports host-specific modules
imports = [
  ./hardware-configuration.nix  # Hardware scan results
  ./networking.nix              # Host network configuration
  ./hardware.nix                # Host hardware optimization
];
```

### 5. Home Manager Layer (`home/`)
```nix
# User-level configuration, manages user programs and settings
imports = [
  ./programs    # Program configurations
  ./shell       # Shell environment
  ./desktop     # Desktop user configuration
];
```

## 🚀 Deployment Methods

### Initial Deployment
```bash
# Clone configuration
git clone <your-repo> ~/.config/nix-config
cd ~/.config/nix-config

# Deploy system configuration
sudo nixos-rebuild switch --flake .#tb-amd-6800h
```

### Daily Updates
```bash
# Switch configuration
sudo nixos-rebuild switch --flake .

# Update system
sudo nixos-rebuild switch --upgrade --flake .

# Clean old generations
sudo nix-collect-garbage -d
```

### Development Environment
```bash
# Enter development environment (includes nil, nixfmt, etc.)
nix develop

# Format Nix code
nix fmt
```

## 🎨 Featured Functionality

### 🖥️ Desktop Environment
- **KDE Plasma 6**: Modern desktop environment
- **PipeWire**: Unified audio solution
- **Chinese Input Method**: Fcitx5 + Rime
- **Font Configuration**: Nerd Fonts + Chinese font support

### 🛠️ Development Environment
- **Multi-language Support**: Python, Node.js, Rust, Go, Java, Haskell
- **Containerization**: Docker + Podman
- **Virtualization**: KVM/QEMU + libvirt
- **Editors**: Neovim + VS Code

### 🏠 Home Manager
- **Shell**: Zsh + Oh My Zsh + Starship
- **Terminal Tools**: ripgrep, fd, bat, exa, fzf
- **Git Configuration**: Complete Git workflow configuration
- **Program Configuration**: Unified management of all user programs

## 🔧 Custom Configuration

### Adding New Hosts
1. Create a new host folder in the `hosts/` directory
2. Copy `hardware-configuration.nix`
3. Add new configuration in `flake.nix`:
```nix
nixosConfigurations.new-host = myLib.mkHost {
  hostname = "new-host";
  username = "vollate";
  desktop = "plasma"; # Or other desktop environments
};
```

### Adding New Desktop Environments
1. Create a new desktop module in `modules/desktop/`
2. Add conditional import in `modules/desktop/default.nix`
3. Specify the `desktop` parameter when using

### Customizing Home Manager
Modify the corresponding files under `home/vollate/`:
- `programs/`: Add new program configurations
- `shell/`: Modify shell settings
- `desktop/`: Adjust desktop user configuration

## 📚 Reference Resources

- [NixOS & Nix Flakes Book](https://nixos-and-flakes.thiscute.world/)
- [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)

## 📝 License

MIT License - See [LICENSE](LICENSE) file for details

---

> 💡 **Tip**: This configuration is designed for learning and reference. Please adjust according to your hardware and requirements. 