FROM python:3.11-slim

ARG VERSION
LABEL org.opencontainers.image.version="${VERSION}"

WORKDIR /app
COPY pyproject.toml .
RUN pip install .

COPY solar_flare_finder solar_flare_finder
COPY docker/entrypoint.sh /entrypoint.sh

CMD ["/entrypoint.sh"]
