{ config, lib, pkgs, ... }:

{
  programs.gpg = {
    enable = true;
    
    settings = {
      # 基础设置
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";
      charset = "utf-8";
      
      # 显示设置
      fixed-list-mode = true;
      no-comments = true;
      no-emit-version = true;
      no-greeting = true;
      keyid-format = "0xlong";
      list-options = "show-uid-validity";
      verify-options = "show-uid-validity";
      with-fingerprint = true;
      
      # 行为设置
      use-agent = true;
      require-cross-certification = true;
      no-symkey-cache = true;
      throw-keyids = true;
    };
  };

  # GPG Agent 服务
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    
    # 缓存设置 (秒)
    defaultCacheTtl = 1800;        # 30 分钟
    defaultCacheTtlSsh = 1800;     # 30 分钟
    maxCacheTtl = 7200;            # 2 小时
    maxCacheTtlSsh = 7200;         # 2 小时
    
    # Pin entry 程序
    pinentryPackage = pkgs.pinentry-curses;
  };
  
  # Shell 环境变量
  home.sessionVariables = {
    # 确保 GPG TTY 正确设置
    GPG_TTY = "$(tty)";
  };
} 