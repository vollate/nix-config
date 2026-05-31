{
  config,
  lib,
  pkgs,
  ...
}:

let
  pinentryMuxScript = pkgs.writeText "pinentry-mux.py" ''
    import os
    import subprocess
    import sys


    if len(sys.argv) < 3:
        sys.stdout.write("ERR 83886179 missing pinentry backends\n")
        sys.stdout.flush()
        sys.exit(1)

    curses_backend = sys.argv[1]
    qt_backend = sys.argv[2]
    backend_args = sys.argv[3:]

    ttyname = None
    display_option = None


    def send_to_agent(data):
        sys.stdout.buffer.write(data)
        sys.stdout.buffer.flush()


    def valid_tty(value):
        return value and (value.startswith("/dev/pts/") or value.startswith("/dev/tty"))


    def parse_option(line):
        global ttyname, display_option
        text = line.decode("utf-8", "replace").strip()
        if text.startswith("OPTION ttyname="):
            ttyname = text.split("=", 1)[1]
        elif text.startswith("OPTION display="):
            display_option = text.split("=", 1)[1]


    def choose_backend():
        if valid_tty(ttyname) or os.environ.get("SSH_CONNECTION"):
            return curses_backend
        if display_option or os.environ.get("DISPLAY") or os.environ.get("WAYLAND_DISPLAY"):
            return qt_backend
        return curses_backend


    if any(arg in ("--help", "--version") for arg in backend_args):
        backend_path = choose_backend()
        os.execv(backend_path, [backend_path, *backend_args])


    def start_backend():
        path = choose_backend()
        proc = subprocess.Popen(
            [path, *backend_args],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=sys.stderr,
        )

        # The real pinentry greets gpg-agent. The mux has already done that, so
        # consume the backend greeting before forwarding cached commands.
        greeting = proc.stdout.readline()
        if not greeting.startswith(b"OK"):
            send_to_agent(b"ERR 83886179 pinentry backend failed\n")
            sys.exit(1)
        return proc


    def send_command_to_backend(proc, line):
        proc.stdin.write(line)
        proc.stdin.flush()

        responses = []
        while True:
            response = proc.stdout.readline()
            if response == b"":
                return None

            responses.append(response)
            stripped = response.lstrip()
            if stripped.startswith(b"OK") or stripped.startswith(b"ERR"):
                return responses


    def replay_cached_options(proc):
        for cached_line in cached_options:
            responses = send_command_to_backend(proc, cached_line)
            if responses is None:
                send_to_agent(b"ERR 83886179 pinentry backend exited\n")
                return False
        return True


    def forward_command(proc, line):
        responses = send_command_to_backend(proc, line)
        if responses is None:
            send_to_agent(b"ERR 83886179 pinentry backend exited\n")
            return False
        for response in responses:
            send_to_agent(response)
        return True


    # Initial pinentry greeting.
    send_to_agent(b"OK Pleased to meet you\n")

    cached_options = []
    proc = None

    for line in sys.stdin.buffer:
        parse_option(line)

        if line.startswith(b"OPTION "):
            cached_options.append(line)
            send_to_agent(b"OK\n")
            continue

        proc = start_backend()
        if not replay_cached_options(proc):
            sys.exit(1)
        if not forward_command(proc, line):
            sys.exit(1)
        if line.startswith(b"BYE"):
            sys.exit(0)
        break

    if proc is None:
        sys.exit(0)

    for line in sys.stdin.buffer:
        if not forward_command(proc, line):
            sys.exit(1)
        if line.startswith(b"BYE"):
            break
  '';
  pinentryWrapper = pkgs.writeShellScriptBin "pinentry" ''
    exec ${pkgs.python3}/bin/python3 ${pinentryMuxScript} \
      ${pkgs.pinentry-curses}/bin/pinentry-curses \
      ${pkgs.pinentry-qt}/bin/pinentry-qt \
      "$@"
  '';
in
{
  # Security configurations
  security = {
    rtkit.enable = true;
    polkit.enable = true;

    # Allow users in wheel group to use sudo without password for system management
    sudo.extraRules = [
      {
        users = [ "wheel" ];
        commands = [
          {
            command = "ALL";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };

  # PAM configuration
  security.pam.services = {
    login.enableGnomeKeyring = true;
    lightdm.enableGnomeKeyring = true;
  };

  # GnuPG configuration
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pinentryWrapper;
  };

  # AppArmor (optional, can be enabled for additional security)
  # security.apparmor.enable = true;
}
