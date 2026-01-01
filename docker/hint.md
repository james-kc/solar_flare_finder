```bash
bash dev/build.sh
docker-compose -f docker/docker-compose.yml run flare-updater
docker-compose -f docker/docker-compose.yml up flare-web
```