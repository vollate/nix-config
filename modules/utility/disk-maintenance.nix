{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixosVollate.monitoring.diskMaintenance;
  absolutePath = lib.types.strMatching "/.*";
  settings = pkgs.writeText "disk-maintenance.json" (
    builtins.toJSON {
      inherit (cfg)
        scrubs
        selfTests
        pollInterval
        lockFile
        ;
    }
  );
  runner = pkgs.writeShellApplication {
    name = "disk-maintenance";
    runtimeInputs = [
      pkgs.python3
      pkgs.smartmontools
      pkgs.btrfs-progs
      pkgs.util-linux
    ];
    text = ''exec python3 ${./disk-maintenance.py} ${settings} "$@"'';
  };
  service = kind: id: target: {
    name = "disk-maintenance-${kind}-${id}";
    value = {
      description = "Monthly disk ${kind}: ${id}";
      after = [ "local-fs.target" ];
      unitConfig.RequiresMountsFor = lib.optional (kind == "scrub") target.mountPoint;
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${runner}/bin/disk-maintenance ${kind} ${id}";
        TimeoutStartSec = "infinity";
        TimeoutStopSec = "5min";
        KillMode = "mixed";
        Nice = 19;
        IOSchedulingClass = "idle";
        UMask = "0077";
      };
    };
  };
  timer = kind: id: target: {
    name = "disk-maintenance-${kind}-${id}";
    value = {
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = target.calendar;
        Persistent = true;
        AccuracySec = "1min";
        RandomizedDelaySec = 0;
      };
    };
  };
  targets =
    f:
    lib.listToAttrs (
      lib.mapAttrsToList (f "scrub") cfg.scrubs ++ lib.mapAttrsToList (f "selftest") cfg.selfTests
    );
  rule = alert: expr: duration: summary: description: {
    inherit alert expr;
    for = duration;
    annotations = { inherit summary description; };
  };
  days = toString (cfg.overdueAfter / 86400);
  overdue =
    kind: alert:
    rule alert
      ''
        ((disk_maintenance_last_success_timestamp_seconds{kind="${kind}"} > 0)
          and (time() - disk_maintenance_last_success_timestamp_seconds{kind="${kind}"} > ${toString cfg.overdueAfter}))
        or
        ((disk_maintenance_last_success_timestamp_seconds{kind="${kind}"} == 0)
          and (time() - disk_maintenance_monitoring_since_seconds{kind="${kind}"} > ${toString cfg.overdueAfter}))
      ''
      "1h"
      "{{ $labels.target }} has no successful {{ $labels.kind }} within ${days} days"
      "No successful completion is recorded within the allowed interval. Newly monitored targets receive a ${days}-day initial grace period; starting or failing a test does not reset it.";
in
{
  options.nixosVollate.monitoring.diskMaintenance = {
    enable = lib.mkEnableOption "serialized monthly disk maintenance and textfile telemetry";
    scrubs = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            mountPoint = lib.mkOption { type = absolutePath; };
            calendar = lib.mkOption { type = lib.types.str; };
          };
        }
      );
    };
    selfTests = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            device = lib.mkOption { type = absolutePath; };
            protocol = lib.mkOption {
              type = lib.types.enum [
                "ata"
                "nvme"
              ];
            };
            calendar = lib.mkOption { type = lib.types.str; };
            maxDuration = lib.mkOption { type = lib.types.ints.positive; };
          };
        }
      );
    };
    overdueAfter = lib.mkOption {
      type = lib.types.ints.positive;
      default = 3456000;
    };
    pollInterval = lib.mkOption {
      type = lib.types.ints.positive;
      default = 300;
    };
    lockFile = lib.mkOption {
      type = absolutePath;
      default = "/run/lock/disk-maintenance.lock";
    };
    package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = runner;
      internal = true;
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = config.nixosVollate.monitoring.enable;
            message = "Disk maintenance requires monitoring.";
          }
          {
            assertion = !config.services.btrfs.autoScrub.enable;
            message = "Disk maintenance must not run alongside btrfs.autoScrub.";
          }
          {
            assertion = lib.all (id: builtins.match "[a-zA-Z0-9][a-zA-Z0-9_-]*" id != null) (
              builtins.attrNames cfg.scrubs ++ builtins.attrNames cfg.selfTests
            );
            message = "Disk maintenance IDs must be safe unit-name components.";
          }
        ];
        systemd.tmpfiles.rules = [
          "d /var/lib/disk-maintenance 0711 root root -"
          "d /var/lib/disk-maintenance/textfile 0755 root root -"
        ];
        services.prometheus.exporters.node = {
          enabledCollectors = [ "textfile" ];
          extraFlags = [ "--collector.textfile.directory=/var/lib/disk-maintenance/textfile" ];
        };
        systemd.services = targets service // {
          disk-maintenance-status = {
            description = "Read-only disk maintenance telemetry";
            after = [ "local-fs.target" ];
            serviceConfig = {
              Type = "oneshot";
              ExecStart = "${runner}/bin/disk-maintenance status";
              UMask = "0077";
              TimeoutStartSec = "15min";
            };
          };
        };
        systemd.timers = targets timer // {
          disk-maintenance-status = {
            wantedBy = [ "timers.target" ];
            timerConfig = {
              OnBootSec = "2min";
              OnUnitInactiveSec = "${toString cfg.pollInterval}s";
              AccuracySec = "30s";
              Persistent = false;
            };
          };
        };
      }
      (lib.mkIf config.nixosVollate.monitoring.alerting.enable {
        services.prometheus.rules = [
          (builtins.toJSON {
            groups = [
              {
                name = "disk-maintenance";
                rules = [
                  (rule "BtrfsScrubErrors"
                    ''sum by (instance, target) (disk_maintenance_scrub_errors{type=~"read_errors|csum_errors|verify_errors|super_errors|malloc_errors|uncorrectable_errors|unverified_errors|corrected_errors"}) > 0''
                    "5m"
                    "Btrfs scrub found errors on {{ $labels.target }}"
                    "The latest completed scrub reported errors, including any corrected errors. Inspect its status and journal; this alert clears after an error-free completed scrub."
                  )
                  (overdue "scrub" "BtrfsScrubOverdue")
                  (overdue "selftest" "SmartExtendedTestOverdue")
                  (rule "SmartExtendedTestFailed" "disk_maintenance_selftest_failure == 1" "5m"
                    "Extended SMART test failed on {{ $labels.target }}"
                    "A failed extended test has not been superseded by a successful extended test. Check the self-test log and disk health; starting, aborting, or interrupting another test does not clear this alert."
                  )
                  (rule "SmartExtendedTestInterrupted"
                    ''disk_maintenance_selftest_last_result{result=~"aborted|interrupted"} == 1''
                    "30m"
                    "Extended SMART test on {{ $labels.target }} was {{ $labels.result }}"
                    "The test did not complete. This is not itself proof of media failure and does not count as a successful monthly test."
                  )
                  (rule "DiskMaintenanceTelemetryFailed"
                    ''
                      (disk_maintenance_collection_success == 0)
                      or (time() - disk_maintenance_last_poll_timestamp_seconds > 1800)
                      or (disk_maintenance_expected unless on (instance, kind, target) disk_maintenance_last_poll_timestamp_seconds)
                      or absent(disk_maintenance_expected{job="node"})
                      or (node_textfile_scrape_error{job="node"} == 1)
                    ''
                    "15m"
                    "Disk maintenance telemetry is missing, stale, or invalid"
                    "Check disk-maintenance-status.service and node-exporter textfile collection. Missing results must not be interpreted as healthy disks."
                  )
                ];
              }
            ];
          })
        ];
        services.prometheus.alertmanager.configuration.inhibit_rules = [
          {
            source_matchers = [
              ''alertname=~"BtrfsScrubErrors|SmartExtendedTestFailed|SmartExtendedTestInterrupted"''
            ];
            target_matchers = [ ''alertname=~"BtrfsScrubOverdue|SmartExtendedTestOverdue"'' ];
            equal = [
              "instance"
              "target"
            ];
          }
          {
            source_matchers = [ ''alertname="SmartExtendedTestFailed"'' ];
            target_matchers = [ ''alertname="SmartExtendedTestInterrupted"'' ];
            equal = [
              "instance"
              "target"
            ];
          }
        ];
      })
    ]
  );
}
