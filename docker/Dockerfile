# Base image
FROM python:3.11-slim

# Build argument for version (default fallback)
ARG VERSION=0.0.0

# Metadata labels
LABEL org.opencontainers.image.title="solar-flare-finder"
LABEL org.opencontainers.image.version="${VERSION}"
LABEL org.opencontainers.image.authors="James Kavanagh-Cranston"
LABEL org.opencontainers.image.source="https://github.com/james-kc/solar_flare_finder"

# Set working directory
WORKDIR /app

# Copy pyproject and install
COPY ../pyproject.toml ../poetry.lock* /app/
RUN pip install --upgrade pip && pip install .

# Copy the source code
COPY ../solar_flare_finder /app/solar_flare_finder

# Copy entrypoint
COPY ../docker/entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

ENTRYPOINT ["/app/entrypoint.sh"]
