#!/bin/bash
# entrypoint.sh
# Usage: ./entrypoint.sh [command]

set -e

if [ "$1" = "update" ]; then
    echo "Running flare data update..."
    python -m solar_flare_finder.pipeline.update_flare_list
elif [ "$1" = "web" ]; then
    echo "Starting FastAPI web server..."
    uvicorn solar_flare_finder.web.app:app --host 0.0.0.0 --port 8000
else
    echo "Running custom command: $@"
    exec "$@"
fi
