# syntax=docker/dockerfile:1
FROM python:3.12.16-slim-bookworm

RUN apt-get update && \
    apt-get install -y --no-install-recommends apache2-utils && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /seed
COPY . .
RUN python make-data.py && \
    groupadd --system --gid 10001 app && \
    useradd --system --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app
USER 10001
CMD ["/seed/generate-votes.sh"]
