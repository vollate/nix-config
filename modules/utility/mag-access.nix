{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.nixosVollate.magAccess;
  # The checked-in dashboard uses @host@ so the private hostname stays out of this repo.
  dashboardDir = pkgs.writeTextDir "mag-access.json" (
    builtins.replaceStrings [ "@host@" ] [ cfg.host ] (builtins.readFile ./dashboards/mag-access.json)
  );
in
{
  options.nixosVollate.magAccess = {
    enable = lib.mkEnableOption "private Caddy access-log body-byte statistics in Loki/Grafana";
    host = lib.mkOption {
      type = lib.types.strMatching "[a-z0-9.-]+";
      description = "Exact direct-DNS virtual host to collect (without port).";
    };
    port = lib.mkOption {
      type = lib.types.port;
      description = "HTTPS virtual-host port, also accepted in the access-log Host field.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.nixosVollate.monitoring.enable;
        message = "magAccess requires nixosVollate.monitoring.enable for Grafana provisioning.";
      }
      {
        assertion = config.services.caddy.enable;
        message = "magAccess requires Caddy JSON access logs in the journal.";
      }
    ];

    services.alloy = {
      enable = true;
      extraFlags = [
        "--server.http.listen-addr=127.0.0.1:12345"
        "--storage.path=/var/lib/alloy"
        "--disable-reporting"
      ];
    };
    # The upstream unit provides DynamicUser, StateDirectory=alloy and only the
    # systemd-journal supplementary group. Both /run and /var journals stay readable.
    environment.etc."alloy/config.alloy".text = import ./mag-access-alloy.nix {
      inherit lib;
      inherit (cfg) host port;
    };

    services.loki = {
      enable = true;
      dataDir = "/var/lib/loki";
      # Keep extraFlags empty: the NixOS module then validates this at build time.
      configuration = {
        auth_enabled = false; # Local users can query it; NOT an authentication boundary.
        analytics.reporting_enabled = false;
        server = {
          http_listen_address = "127.0.0.1";
          http_listen_port = 3100;
          grpc_listen_address = "127.0.0.1";
          grpc_listen_port = 9095;
        };
        common = {
          path_prefix = "/var/lib/loki";
          instance_addr = "127.0.0.1";
          replication_factor = 1;
          ring.kvstore.store = "inmemory";
          storage.filesystem = {
            chunks_directory = "/var/lib/loki/chunks";
            rules_directory = "/var/lib/loki/rules";
          };
        };
        schema_config.configs = [
          {
            from = "2024-01-01";
            store = "tsdb";
            object_store = "filesystem";
            schema = "v13";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
        storage_config.tsdb_shipper = {
          active_index_directory = "/var/lib/loki/tsdb-index";
          cache_location = "/var/lib/loki/tsdb-cache";
        };
        ingester.wal = {
          enabled = true;
          dir = "/var/lib/loki/wal";
        };
        compactor = {
          working_directory = "/var/lib/loki/compactor";
          retention_enabled = true;
          delete_request_store = "filesystem";
          retention_delete_delay = "2h";
          retention_delete_worker_count = 2;
          compaction_interval = "10m";
        };
        limits_config = {
          retention_period = "720h";
          max_query_parallelism = 2;
          tsdb_max_query_parallelism = 2;
          # The dashboard offers a complete 30-day retained-range query.
          max_query_length = "744h";
        };
        querier.max_concurrent = 2;
        chunk_store_config.chunk_cache_config.embedded_cache = {
          enabled = true;
          max_size_mb = 64;
        };
        query_range = {
          cache_results = true;
          results_cache.cache.embedded_cache = {
            enabled = true;
            max_size_mb = 32;
          };
        };
      };
    };

    services.grafana.provision = {
      datasources.settings.datasources = [
        {
          name = "Loki";
          uid = "loki";
          type = "loki";
          access = "proxy";
          url = "http://127.0.0.1:3100";
          isDefault = false;
          editable = false;
        }
      ];
      dashboards.settings.providers = [
        {
          name = "mag-access";
          type = "file";
          options.path = dashboardDir;
        }
      ];
    };
    # No firewall changes and no public reverse proxy for Loki or Alloy.
  };
}
