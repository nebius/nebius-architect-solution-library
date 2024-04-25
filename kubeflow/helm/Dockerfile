FROM bitnami/kubectl
ARG argocd_bin_url=https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
ARG deployKF_git_url=https://github.com/deployKF/deployKF.git
ARG deployKF_commit=0c8caf9180736faaea3e686f7bb0335507a505b8
USER root
RUN apt update && apt install -y curl wget neovim git
RUN curl -sSL -o argocd-linux-amd64 $argocd_bin_url && install -m 555 argocd-linux-amd64 /usr/local/bin/argocd && rm argocd-linux-amd64
RUN git clone https://github.com/deployKF/deployKF.git /deployKF
WORKDIR /deployKF
RUN git checkout $deployKF_commit