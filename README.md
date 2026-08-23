# Ea — Automated SOAR Platform

> Security Orchestration, Automation and Response with Wazuh, n8n and Ollama.

Ea is a modular SOAR deployment focused on automating the flow from security detection to analysis, decision support, and response.

## Architecture

```text
Wazuh
  │
  │ Security Alert
  ▼
n8n
  │
  ├──► Ollama
  │      └── Local AI-assisted analysis
  │
  ├──► DefectDojo
  │      └── Vulnerability / finding management
  │
  └──► Response integrations
         └── pfSense or other enforcement systems
```

### Component responsibilities

| Component | Role |
|---|---|
| Wazuh | Security monitoring and detection |
| n8n | Security orchestration and automation |
| Ollama | Local AI-assisted analysis and decision support |
| DefectDojo | Vulnerability and security finding management |
| pfSense / other controls | Response and enforcement |

Ea does **not** delegate unrestricted response actions to the LLM. Ollama is an analysis/decision-support component; deterministic n8n workflows and explicit policies should control response actions.

## Repository structure

```text
Ea/
├── defectdojo/
│   └── README.md
├── n8n/
│   └── docker-compose.yml
├── ollama/
│   └── docker-compose.yml
├── .env.example
├── .gitignore
└── README.md
```

## Prerequisites

- Docker Desktop
- Docker Compose
- Wazuh deployed separately or reachable from the n8n host
- NVIDIA Container Toolkit / NVIDIA Docker support if Ollama will use an NVIDIA GPU

## Configuration

Copy the example environment file:

```bash
cp .env.example .env
```

On Windows PowerShell:

```powershell
Copy-Item .env.example .env
```

Set the Wazuh, DefectDojo, and Ollama connection values before running workflows.

**Never commit `.env`.** API credentials and passwords belong only in the local `.env` file or a dedicated secret manager.

## Deploy n8n

```bash
cd n8n
docker compose up -d
```

n8n is exposed on:

```text
http://localhost:5678
```

Persistent n8n data is stored in `n8n/n8n_data/` and is ignored by Git.

## Deploy Ollama

```bash
cd ollama
docker compose up -d
```

Ollama is exposed on:

```text
http://localhost:11434
```

The deployment is configured for NVIDIA GPU access. If the host does not provide a supported NVIDIA runtime, remove the GPU reservation from `ollama/docker-compose.yml` before starting the service.

Pull the model required by the workflow, for example:

```bash
docker exec -it ea-ollama ollama pull <model>
```

Use the model name expected by the n8n workflow.

## DefectDojo

DefectDojo is intentionally treated as a separate vulnerability/finding-management service rather than as the SOAR engine.

The official DefectDojo Docker Compose deployment requires the complete DefectDojo source tree because its compose file builds application images from files in that repository. Do not keep a standalone copied compose file and assume it is self-contained.

See `defectdojo/README.md` for the deployment procedure.

## Integration flow

The intended automation flow is:

```text
1. Wazuh detects an event
        ↓
2. n8n receives / retrieves the alert
        ↓
3. n8n normalizes the event and extracts indicators
        ↓
4. Ollama provides local AI-assisted analysis
        ↓
5. n8n applies deterministic rules / policy
        ↓
6. n8n performs the approved response
        ↓
7. DefectDojo and/or other systems receive the resulting finding
```

The exact workflow implementation belongs in n8n. This repository currently provides the deployment foundation; it should not claim workflows or integrations that are not actually committed.

## Security notes

- Do not commit `.env`, API keys, passwords, or tokens.
- Do not expose n8n or Ollama directly to the Internet without appropriate access controls.
- Use dedicated API credentials with the minimum required privileges.
- Treat LLM output as untrusted input.
- Validate and constrain automated response actions with deterministic policies.
- Review firewall/API permissions before enabling automatic containment.

## Project scope

Ea is an automation platform, not a replacement for Wazuh, DefectDojo, or the firewall. Each component has a defined responsibility and communicates through controlled integrations.

## Status

The deployment layer is intentionally modular. Detection, orchestration, AI-assisted analysis, vulnerability management, and response integrations can be enabled independently as the project evolves.
