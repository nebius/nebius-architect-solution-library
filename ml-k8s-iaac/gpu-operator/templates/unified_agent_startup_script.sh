MONITORING_API_ADDRESS="https://monitoring.api.nemax.nebius.cloud"

folder_id="$(curl -H 'Metadata-Flavor:Google' -s http://169.254.169.254/computeMetadata/v1/instance/vendor/folder-id)"
vm_id="$(curl -H 'Metadata-Flavor:Google' -s http://169.254.169.254/computeMetadata/v1/instance/id)"

if [ ! -f /etc/unified_agent/config.yaml ]; then
echo "Installing unified agent config"

while true; do
    dcgm_ip="$(/home/kubernetes/bin/crictl inspectp -o json $(/home/kubernetes/bin/crictl pods | grep "nvidia-dcgm-exporter" | awk '{print $1}') | jq -r '.status.network.ip')"
    if [ ! -z "${dcgm_ip}" ]; then
    break
    fi
    echo "waiting for nvidia-dcgm-exporter container to be ready"
    sleep 5
done

mkdir -p /etc/unified_agent
cat <<EOF > /etc/unified_agent/config.yaml
storages:
  - name: metrics_storage
    plugin: fs
    config:
      directory: /var/lib/unified_agent/metrics_storage
      max_partition_size: 100mb
      max_segment_size: 10mb

channels:
  - name: metrics_channel
    channel:
      pipe:
        - filter:
            plugin: add_metric_labels
            config:
              labels:
                vm_id: "dp7q39f4226mi183suao"
        - filter:
            plugin: transform_metric_labels
            config:
              labels:
                - gpu: "-"
                - device: "-"
                - modelName: "-"
                - Hostname: "-"
                - pod: "-"
                - container: "-"
                - namespace: "-"
                - DCGM_FI_CUDA_DRIVER_VERSION: "-"
                - DCGM_FI_DRIVER_VERSION: "-"
                - DCGM_FI_PROCESS_NAME: "-"
                - DCGM_FI_DEV_BRAND: "-"
                - DCGM_FI_DEV_SERIAL: "-"
                - DCGM_FI_DEV_MINOR_NUMBER: "-"
                - DCGM_FI_DEV_NAME: "-"
        - storage_ref:
            name: metrics_storage
      output:
        plugin: yc_metrics
        config:
          url: "https://monitoring.api.nemax.nebius.cloud/monitoring/v2/data/write"
          folder_id: "yc.marketplace.mkt-test-folder"
          service: compute
          iam:
            cloud_meta: { }

routes:
  - input:
      plugin: metrics_pull
      config:
        url: "http://10.112.140.12:9400/metrics"
        format:
          prometheus: {}
        metric_name_label: name
    channel:
      channel_ref:
        name: metrics_channel
EOF
fi

if [ ! -f /usr/local/bin/unified_agent ]; then
echo "Installing unified agent binary"

s3_bucket_address="https://storage.il.nebius.cloud/yc-unified-agent"
ua_version="$(curl -s ${s3_bucket_address}/latest-version)"
curl -s "${s3_bucket_address}/releases/${ua_version}/unified_agent" -o unified_agent
chmod +x ./unified_agent
mkdir -p /usr/local/bin
mv unified_agent /usr/local/bin/unified_agent
fi

if [ ! -f /etc/systemd/system/unified_agent.service ]; then
echo "Installing unified agent.service"

cat <<'EOF' > /usr/local/bin/unified_agent_pre
#!/usr/bin/env bash

set -eu
set -o pipefail

dcgm_cur_ip="$(grep "9400/metrics" /etc/unified_agent/config.yaml | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}')"
dcgm_new_ip="$(/home/kubernetes/bin/crictl inspectp -o json $(/home/kubernetes/bin/crictl pods | grep "nvidia-dcgm-exporter" | awk '{print $1}') | jq -r '.status.network.ip')"

if [ ! -z "${dcgm_new_ip}" ] && [ "${dcgm_cur_ip}" == "${dcgm_new_ip}" ]; then
exit 0
fi

sed -i "s/${dcgm_cur_ip}/${dcgm_new_ip}/g" /etc/unified_agent/config.yaml
EOF
chmod +x /usr/local/bin/unified_agent_pre

cat <<EOF > /etc/systemd/system/unified_agent.service
[Unit]
Description=unified agent
After=network.target

[Service]
Type=simple
MemoryLimit=500M
ExecStartPre=/usr/local/bin/unified_agent_pre
ExecStart=/usr/local/bin/unified_agent --config /etc/unified_agent/config.yaml
KillMode=process
Restart=always
RestartSec=2s

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload

echo "Enabling and starting unified_agent.service"
systemctl enable unified_agent.service
systemctl start unified_agent.service
fi

echo "unified agent is installed"
echo "metrics will be available at https://console.nebius.ai/folders/${folder_id}/compute/instance/${vm_id}/monitoring?tab=gpu"

sleep infinity