# DefectDojo deployment

DefectDojo is a separate vulnerability/finding-management component of Ea.

## Why the official repository is required

The official DefectDojo Docker Compose deployment is not a single self-contained compose file. Its nginx and Django services build from Dockerfiles and supporting files in the DefectDojo source tree.

Do not copy only `docker-compose.yml` into this folder and expect it to build.

## Recommended deployment

From the Ea parent directory:

```bash
git clone https://github.com/DefectDojo/django-DefectDojo.git defectdojo/runtime
cd defectdojo/runtime
docker compose up -d
```

For the official quick-start and configuration guidance, use the DefectDojo documentation/repository.

The default application port used by the official compose deployment is `8080`.

## Integration with Ea

When DefectDojo is running as a separate Compose project on the same Docker host, n8n should normally reach it through the published host port:

```text
http://host.docker.internal:8080
```

Do not use:

```text
http://defectdojo:8080
```

from the Ea `.env` unless both services have explicitly been attached to the same Docker network.

## Data

The runtime directory is ignored by Ea's Git configuration so the full DefectDojo source tree and local deployment files are not accidentally committed into this repository.
