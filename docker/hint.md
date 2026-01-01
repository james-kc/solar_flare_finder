```
docker build \
  --build-arg VERSION=$(python -m build --wheel >/dev/null && \
    python -c "from importlib.metadata import version; print(version('solar-flare-finder'))") \
  -t solar-flare-finder .
```