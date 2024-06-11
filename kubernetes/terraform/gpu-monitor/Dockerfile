FROM cr.nemax.nebius.cloud/k8s/k8s-addons/node-problem-detector/node-problem-detector:v0.8.0 as node-problem-detector

FROM nvidia/cuda:12.2.2-base-ubuntu22.04

COPY --from=node-problem-detector /node-problem-detector /node-problem-detector

COPY --from=node-problem-detector /config/ /config

COPY nvidia-smi.sh /config/
RUN chmod +x /config/nvidia-smi.sh
COPY nvidia-smi-config.json /config/