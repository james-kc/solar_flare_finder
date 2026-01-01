#!/bin/bash
# dev/build.sh
# Build Docker images with the version from Python

set -e

# Read the version from your Python package
export VERSION=$(python -c "from solar_flare_finder.version import __version__; print(__version__)")

# Build Docker images using docker-compose
docker-compose -f docker/docker-compose.yml build
