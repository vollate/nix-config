{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Enable tmpfs for /tmp
  boot.tmp.useTmpfs = true;

  # Kernel OOM is the last resort, after earlyoom has tried to keep the desktop responsive.
  boot.kernel.sysctl = {
    "vm.panic_on_oom" = 0;
    # Select by OOM badness, not whichever process happened to request memory last.
    "vm.oom_kill_allocating_task" = 0;
    "vm.oom_dump_tasks" = 1;
    # Keep heuristic overcommit; strict mode breaks applications reserving large address spaces.
    "vm.overcommit_memory" = 0;
  };

  # Use one proactive killer. earlyoom targets a process rather than an entire session cgroup.
  systemd.oomd.enable = lib.mkDefault false;
  services.earlyoom = {
    enable = true;
    freeMemThreshold = 5;
    freeMemKillThreshold = 2;
    # Act on RAM pressure even with unused swap (also works on swapless hosts).
    freeSwapThreshold = 100;
    freeSwapKillThreshold = 100;
  };
}
