{ ... }:

{
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = true;
      X11Forwarding = true;
      AcceptEnv = [ "LANG LC_*" ];
      ClientAliveInterval = 60;
      ClientAliveCountMax = 10;
    };
    allowSFTP = true;
    # openFirewall defaults to true — automatically opens port 22
    openFirewall = true;
  };
}
