{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixosVollate.monitoring;
  dashboard = name: id: revision: hash: {
    inherit name;
    src = pkgs.fetchurl {
      url = "https://grafana.com/api/dashboards/${id}/revisions/${revision}/download";
      inherit hash;
    };
  };
  dashboards = [
    (dashboard "node" "1860" "46" "sha256-5Y3cXcU11MkB+U2pZIvD49Wue2946Y4YW86LKJlhzqM=")
    (dashboard "smartctl" "22604" "4" "sha256-ah36BdFIcaprUz39hRzuYVzfp3diEBckmalMaOls5kY=")
  ]
  ++ lib.optional cfg.nvidia.enable (
    dashboard "nvidia" "14574" "18" "sha256-tuvm63s/svcc15DikhT94M5exnscMfQCehbqOBX7GGk="
  );
  dashboardDir = pkgs.runCommand "monitoring-dashboards" { nativeBuildInputs = [ pkgs.python3 ]; } ''
    mkdir -p "$out"
    ${lib.concatMapStringsSep "\n" (d: ''
        python3 - '${d.src}' "$out/${d.name}.json" <<'PY'
      import json, sys
      text = open(sys.argv[1]).read()
      # File provisioning does not resolve grafana.com import inputs.
      for name in ("ds_prometheus", "DS_PROMETHEUS", "datasource"):
          text = text.replace("$" + "{" + name + "}", "prometheus")
      data = json.loads(text)
      data.pop("__inputs", None)
      data["templating"]["list"] = [v for v in data["templating"]["list"] if v.get("type") != "datasource"]
      with open(sys.argv[2], "w") as out:
          json.dump(data, out)
      PY
    '') dashboards}
  '';

  tg = cfg.alerting.telegram;
  # SMART counters alert on growth so drives with old, stable bad sectors stay quiet.
  alertRules = [
    {
      alert = "TargetDown";
      expr = "up == 0";
      for = "5m";
      annotations.summary = "{{ $labels.job }} exporter is unreachable";
    }
    {
      alert = "SmartFailing";
      expr = "smartctl_device_smart_status == 0";
      annotations.summary = "{{ $labels.device }} reports a failing SMART status";
    }
    {
      alert = "SmartSectorsGrowing";
      expr = ''delta(smartctl_device_attribute{attribute_value_type="raw", attribute_name=~"Reallocated_Sector_Ct|Current_Pending_Sector|Offline_Uncorrectable|Reported_Uncorrect"}[1h]) > 0'';
      annotations.summary = "{{ $labels.device }} {{ $labels.attribute_name }} increased by {{ $value }}";
    }
    {
      alert = "NvmeCriticalWarning";
      expr = "smartctl_device_critical_warning > 0";
      annotations.summary = "{{ $labels.device }} reports NVMe critical warning {{ $value }}";
    }
    {
      alert = "NvmeMediaErrors";
      expr = "delta(smartctl_device_media_errors[1h]) > 0";
      annotations.summary = "{{ $labels.device }} logged {{ $value }} new media errors";
    }
    {
      alert = "DiskHot";
      expr = ''smartctl_device_temperature{temperature_type="current", device=~"sd.+"} > 50 or smartctl_device_temperature{temperature_type="current", device=~"nvme.+"} > 70'';
      for = "10m";
      annotations.summary = "{{ $labels.device }} is at {{ $value }}°C";
    }
    {
      alert = "FilesystemAlmostFull";
      expr = ''min by (device) (node_filesystem_avail_bytes{fstype=~"btrfs|ext4|xfs|vfat"} / node_filesystem_size_bytes) < 0.10'';
      for = "15m";
      annotations.summary = "{{ $labels.device }} has {{ $value | humanizePercentage }} free";
    }
    {
      alert = "BtrfsDeviceErrors";
      expr = "increase(node_btrfs_device_errors_total[1h]) > 0";
      annotations.summary = "btrfs {{ $labels.device }} logged new {{ $labels.type }} errors";
    }
    {
      alert = "BcacheIoErrors";
      expr = "delta(node_bcache_io_errors[1h]) > 0";
      annotations.summary = "bcache {{ $labels.cache_device }} logged new IO errors";
    }
    {
      alert = "SystemdUnitFailed";
      expr = ''node_systemd_unit_state{state="failed"} == 1'';
      for = "5m";
      annotations.summary = "{{ $labels.name }} has failed";
    }
    {
      alert = "MemoryLow";
      expr = "node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < 0.05";
      for = "10m";
      annotations.summary = "Only {{ $value | humanizePercentage }} memory available";
    }
  ];
in
{
  options.nixosVollate.monitoring = {
    enable = lib.mkEnableOption "Prometheus and Grafana monitoring";
    nvidia.enable = lib.mkEnableOption "NVIDIA polling (may keep the discrete GPU awake)";
    alerting = {
      enable = lib.mkEnableOption "Alertmanager with Telegram notifications";
      telegram = {
        chatId = lib.mkOption {
          type = lib.types.int;
          description = "Telegram chat that receives alerts.";
        };
        botTokenFile = lib.mkOption {
          type = lib.types.str;
          description = "Runtime path of the bot token, passed to Alertmanager as a systemd credential.";
        };
        proxyUrl = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          description = "HTTP proxy for reaching api.telegram.org.";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.prometheus = {
          enable = true;
          listenAddress = "127.0.0.1";
          retentionTime = "90d";
          globalConfig.scrape_interval = "15s";
          exporters = {
            node = {
              enable = true;
              listenAddress = "127.0.0.1";
              enabledCollectors = [
                "systemd"
                "processes"
              ];
            };
            smartctl = {
              enable = true;
              listenAddress = "127.0.0.1";
              devices = [ ];
            };
            nvidia-gpu = {
              enable = cfg.nvidia.enable;
              listenAddress = "127.0.0.1";
            };
          };
          scrapeConfigs =
            map
              (name: {
                job_name = name;
                static_configs = [
                  { targets = [ "127.0.0.1:${toString config.services.prometheus.exporters.${name}.port}" ]; }
                ];
              })
              (
                [
                  "node"
                  "smartctl"
                ]
                ++ lib.optional cfg.nvidia.enable "nvidia-gpu"
              );
        };

        services.grafana = {
          enable = true;
          settings = {
            server = {
              http_addr = "127.0.0.1";
              http_port = 3002;
            };
            users.allow_sign_up = false;
            users.auto_assign_org = false;
            "auth.anonymous".enabled = false;
            analytics = {
              reporting_enabled = false;
              check_for_updates = false;
              check_for_plugin_updates = false;
            };
          };
          provision = {
            enable = true;
            datasources.settings = {
              apiVersion = 1;
              datasources = [
                {
                  name = "Prometheus";
                  uid = "prometheus";
                  type = "prometheus";
                  access = "proxy";
                  url = "http://127.0.0.1:${toString config.services.prometheus.port}";
                  isDefault = true;
                  editable = false;
                }
              ];
            };
            dashboards.settings = {
              apiVersion = 1;
              providers = [
                {
                  name = "monitoring";
                  type = "file";
                  options.path = dashboardDir;
                }
              ];
            };
          };
        };
      }

      (lib.mkIf cfg.alerting.enable {
        services.prometheus = {
          rules = [
            (builtins.toJSON {
              groups = [
                {
                  name = "monitoring";
                  rules = alertRules;
                }
              ];
            })
          ];
          alertmanagers = [
            {
              static_configs = [
                { targets = [ "127.0.0.1:${toString config.services.prometheus.alertmanager.port}" ]; }
              ];
            }
          ];
          alertmanager = {
            enable = true;
            listenAddress = "127.0.0.1";
            # Clustering otherwise listens on 0.0.0.0:9094.
            extraFlags = [ "--cluster.listen-address=" ];
            configuration = {
              route = {
                receiver = "telegram";
                group_by = [
                  "alertname"
                  "device"
                ];
                group_wait = "30s";
                group_interval = "5m";
                repeat_interval = "4h";
              };
              receivers = [
                {
                  name = "telegram";
                  telegram_configs = [
                    (
                      {
                        bot_token_file = "/run/credentials/alertmanager.service/telegram_bot_token";
                        chat_id = tg.chatId;
                        send_resolved = true;
                      }
                      // lib.optionalAttrs (tg.proxyUrl != null) { http_config.proxy_url = tg.proxyUrl; }
                    )
                  ];
                }
              ];
            };
          };
        };

        # Alertmanager runs with DynamicUser, so the token cannot be owned by its user.
        systemd.services.alertmanager.serviceConfig.LoadCredential = [
          "telegram_bot_token:${tg.botTokenFile}"
        ];
      })
    ]
  );
}
