# Migration from the previous Ea layout

Replace the contents of the existing repository with this package.

## Keep

- `n8n/`
- `ollama/`
- `defectdojo/`
- `.gitignore`
- `.env.example`
- `README.md`

## Before replacing

1. Back up the existing `.env`.
2. Back up `n8n/n8n_data/` if it contains workflows or credentials.
3. Back up `ollama/ollama_data/` if you already pulled models.
4. If you have a working DefectDojo installation, keep its database/volumes.

## Important

The previous `.env.example` contained a password-like value. Treat any credential that was ever used there as exposed and rotate it.

The previous DefectDojo compose file was not self-contained: it builds from Dockerfiles and directories that were not present in the Ea repository. The revised layout therefore keeps DefectDojo as a documented external runtime instead of pretending the compose file alone is deployable.

## After replacement

Copy your real values into `.env`:

```powershell
Copy-Item .env.example .env
```

Then start services independently:

```powershell
cd n8n
docker compose up -d

cd ..\ollama
docker compose up -d
```

Deploy DefectDojo separately under `defectdojo/runtime` as described in `defectdojo/README.md`.
