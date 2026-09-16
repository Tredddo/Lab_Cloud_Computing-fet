FROM docker.io/debian:bookworm-slim AS downloader

ENV DEBIAN_FRONTEND=noninteractive

ARG BASE_URL="https://lalescu.ro/liviu/fet/download/bin/"

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    xz-utils \
    ca-certificates

WORKDIR /download

RUN mkdir extracted && \
    FILENAME=$(curl -s "${BASE_URL}" | grep -oE 'fet-[0-9.]+-bin\.tar\.xz' | head -n 1) && \
    echo "$FILENAME" && \
    wget -O fet-bin.tar.xz "${BASE_URL}${FILENAME}" && \
    tar -xf fet-bin.tar.xz -C extracted --strip-components=1



FROM docker.io/debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C.UTF-8

#RUN apt-get update && apt-get install -y --no-install-recommends \
#    libglib2.0-0 \
#    ca-certificates

RUN apt-get update && apt-get install -y --no-install-recommends \
    libqt5core5a \
    libqt5xml5 \
    libqt5network5 \
    libglib2.0-0 \
    libqt5gui5 \
    libqt5widgets5 \
    libgl1 \
    libopengl0 \
    libxcb-cursor0 \
    ca-certificates

WORKDIR /app/fet
RUN mkdir -p /app/data

COPY --from=downloader /download/extracted /app/fet/

RUN chmod +x /app/fet/bin/fet && chmod +x /app/fet/bin/fet-cl

WORKDIR /app/fet/bin

ENTRYPOINT ["/app/fet/bin/fet-cl"]
CMD ["--help"]

LABEL org.opencontainers.image.licenses="AGPL-3.0"
LABEL org.opencontainers.image.authors="Liviu Lalescu (FET) / Custom Dockerized by Tredddo"
LABEL org.opencontainers.image.title="FET - Free Timetabling Software"
LABEL org.opencontainers.image.description="Dockerized version of FET command-line interface"
LABEL org.opencontainers.image.source="https://github.com/Tredddo/Lab_Cloud_Computing-fet"
LABEL org.opencontainers.image.url="https://lalescu.ro/liviu/fet/"
