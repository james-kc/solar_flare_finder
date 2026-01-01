#!/bin/sh
solar-flare-finder update
uvicorn solar_flare_finder.web.app:app --host 0.0.0.0 --port 8000
