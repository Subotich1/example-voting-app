# syntax=docker/dockerfile:1
# Base image pinned to an exact version (Dependabot keeps it current)
FROM python:3.12.16-slim-bookworm AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /usr/local/app

COPY requirements.txt ./
RUN pip install -r requirements.txt

# Dedicated unprivileged user with a fixed numeric UID (works with runAsNonRoot in k8s)
RUN groupadd --system --gid 10001 app && \
    useradd --system --uid 10001 --gid app --no-create-home --shell /usr/sbin/nologin app

# dev: auto-reload for local development
FROM base AS dev
RUN pip install watchdog
ENV FLASK_DEBUG=1
USER 10001
CMD ["python", "app.py"]

# final: production image
FROM base AS final
COPY --chown=root:root . .
USER 10001
EXPOSE 8080
HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
  CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8080/', timeout=4)"]
CMD ["gunicorn", "app:app", "-b", "0.0.0.0:8080", "--log-file", "-", "--access-logfile", "-", "--workers", "4", "--keep-alive", "0"]
