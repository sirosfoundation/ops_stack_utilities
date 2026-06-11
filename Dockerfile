FROM ubuntu:26.04
ARG TARGETARCH

# Installation of "base packages"
RUN \
	apt-get update \
	&& apt-get install -y --no-install-recommends curl ca-certificates gettext \
	&& rm -rf /var/lib/apt-get/lists/* \
	&& apt-get autoremove -y


# Installation of kubectl
ARG KUBECTL_VERSION="1.36.1"
ARG KUBECTL_AMD64_HASH="629d3f410e09bf49b64ae7079f7f0bda1191efed311f7d37fdbab0ad5b0ec2b7"
ARG KUBECTL_ARM64_HASH="59f7ee8e477fae658447607dc3c8790ac17a1b016c01c622c12070e969e2d4e7"

RUN \
  if [ "${TARGETARCH}" = "amd64" ]; then HASH="${KUBECTL_AMD64_HASH}"; \
  else HASH="${KUBECTL_ARM64_HASH}"; fi \
  && curl \
    -L -o /usr/local/bin/kubectl \
    "http://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/${TARGETARCH}/kubectl" \
  && echo "${HASH} /usr/local/bin/kubectl" | sha256sum --check \
  && chmod 755 /usr/local/bin/kubectl 

# Installation of Helm
ARG HELM_VERSION="4.2.0"
ARG HELM_AMD64_HASH="97dbeb971be4ac4b27e3839976d9564c0fb35c6f3b1da89dd1e292d236af4096"
ARG HELM_ARM64_HASH="1f8de130dfbd04de64978e7b852a7a547be1404956a366608276d2520b678670"

WORKDIR /tmp
RUN \
  if [ "${TARGETARCH}" = "amd64" ]; then HASH="${HELM_AMD64_HASH}"; \
  else HASH="${HELM_ARM64_HASH}"; fi \
  && curl -L -o helm.tar.gz \
    "https://get.helm.sh/helm-v${HELM_VERSION}-linux-${TARGETARCH}.tar.gz" \
  && echo "${HASH} helm.tar.gz" | sha256sum --check \
  && tar vxf helm.tar.gz \
  && install "linux-${TARGETARCH}/helm" /usr/local/bin \
  && rm -rf helm.tar.gz "linux-${TARGETARCH}"

# Installation of MongoDB Shell (mongosh)
ARG MONGOSH_VERSION="2.8.3"
ARG MONGOSH_AMD64_HASH="3072b3bdbd3181ca74b733bac70e8c2ff13d6444412a96995defaa0f1a427401"
ARG MONGOSH_ARM64_HASH="4991959658ea0feb79a7cece3085e9baafc55120b7ac778c851a529d7c2e7f1a"

WORKDIR /tmp
RUN \
  if [ "${TARGETARCH}" = "amd64" ]; then HASH="${MONGOSH_AMD64_HASH}"; \
  else HASH="${MONGOSH_ARM64_HASH}"; fi \
  && curl -L -o mongosh.deb \
    "https://downloads.mongodb.com/compass/mongodb-mongosh_${MONGOSH_VERSION}_${TARGETARCH}.deb" \
  && echo "${HASH} mongosh.deb" | sha256sum --check \
  && dpkg --install mongosh.deb \
  && rm mongosh.deb

# Runtime configuration
WORKDIR /home/ubuntu
USER ubuntu
