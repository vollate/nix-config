{ ... }:

{
  services.prometheus.scrapeConfigs = [
    {
      job_name = "openwrt";
      scrape_interval = "30s";
      scrape_timeout = "10s";
      metrics_path = "/metrics";
      static_configs = [
        {
          targets = [ "192.168.1.1:9100" ];
          labels = {
            host = "soft-router";
            platform = "openwrt";
            service_manager = "procd";
          };
        }
      ];
    }
  ];
}
