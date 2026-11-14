{
  lib,
  host,
  port,
}:
let
  octet = "(25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])";
  ipv4 = "${octet}(\\.${octet}){3}";
  h = "[0-9A-Fa-f]{1,4}";
  # IPv6, including compressed and IPv4-mapped forms; no forwarded headers or zones.
  ipv6 = lib.concatStringsSep "|" (
    [
      "(${h}:){7}${h}"
      "(${h}:){6}${ipv4}"
    ]
    ++ lib.concatMap (
      left:
      map (
        right:
        let
          l = lib.concatStringsSep ":" (lib.replicate left h);
          r = lib.concatStringsSep ":" (lib.replicate right h);
        in
        "${l}::${r}"
      ) (lib.range 0 (7 - left))
    ) (lib.range 0 7)
    ++ lib.concatMap (
      left:
      map (
        right:
        let
          l = lib.concatStringsSep ":" (lib.replicate left h);
          r = lib.concatStringsSep ":" ((lib.replicate right h) ++ [ ipv4 ]);
        in
        "${l}::${r}"
      ) (lib.range 0 (5 - left))
    ) (lib.range 0 5)
  );
  ipRegex = "^(${ipv4}|${ipv6})$";
  valid = lib.concatStringsSep " && " [
    "type(request.host) == 'string'"
    "type(logger) == 'string'"
    "type(request.remote_ip) == 'string'"
    "type(request.method) == 'string'"
    "type(bytes_read) == 'number'"
    "bytes_read >= `0`"
    "floor(bytes_read) == bytes_read"
    "type(size) == 'number'"
    "size >= `0`"
    "floor(size) == size"
    "type(status) == 'number'"
    "status >= `100`"
    "status <= `599`"
    "floor(status) == status"
    "type(duration) == 'number'"
    "duration >= `0`"
    # Bounded numeric Unix seconds always parse; never fall back on ingestion time.
    "type(ts) == 'number'"
    "ts >= `1000000000`"
    "ts < `4102444800`"
  ];
in
''
  logging {
    level = "info"
  }

  // Keep this name and storage.path stable: they locate the persistent cursor.
  loki.source.journal "mag_access" {
    matches = "_SYSTEMD_UNIT=caddy.service"
    format_as_json = false
    max_age = "1h"
    labels = { service_name = "mag-access" }
    forward_to = [loki.process.mag_access.receiver]
  }

  loki.process "mag_access" {
    stage.json {
      drop_malformed = true
      expressions = {
        valid = ${builtins.toJSON valid},
        logger = "logger",
        host = "request.host",
        client_ip = "request.remote_ip",
        method = "request.method",
        ts = "ts",
        // A JMESPath object is re-encoded by the JSON stage using encoding/json.
        // This is an allowlist, NOT a mutation of the sensitive original record.
        sanitized = "{client_ip: request.remote_ip, received_bytes: bytes_read, sent_bytes: size, method: request.method, status: status, duration: duration}",
      }
    }
    stage.template {
      source = "accepted"
      template = ${builtins.toJSON (''{{ if and (eq .valid "true") (regexMatch ${builtins.toJSON ("(?i)^" + lib.replaceStrings [ "." ] [ "[.]" ] host + "(:${toString port})?$")} .host) (regexMatch "^http[.]log[.]access([.][A-Za-z0-9_-]+)?$" .logger) (regexMatch ${builtins.toJSON ipRegex} .client_ip) (regexMatch "^[!#$%&'*+.^_`|~0-9A-Za-z-]+$" .method) }}true{{ else }}false{{ end }}'')}
    }
    stage.labels {
      values = { accepted = "" }
    }
    stage.match {
      selector = "{accepted!=\"true\"}"
      action = "drop"
      drop_counter_reason = "invalid_or_unrelated_access"
    }
    stage.timestamp {
      source = "ts"
      format = "Unix"
      action_on_failure = "skip"
      action_on_duplicate_timestamp = "keep"
    }
    stage.output {
      source = "sanitized"
    }
    stage.label_keep {
      values = ["service_name"]
    }
    forward_to = [loki.write.local.receiver]
  }

  loki.write "local" {
    endpoint {
      url = "http://127.0.0.1:3100/loki/api/v1/push"
    }
  }
''
