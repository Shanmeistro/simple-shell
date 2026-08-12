FROM ubuntu:22.04
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update \
  && apt-get install -y --no-install-recommends curl ca-certificates \
  && rm -rf /var/lib/apt/lists/*
LABEL org.opencontainers.image.source="https://github.com/shanmeistro/simple-shell"
CMD ["/bin/bash"]
