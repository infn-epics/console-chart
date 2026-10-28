# Epics Console Chart

This Helm chart deploys an EPICS console with Phoebus installed that can be accessed via VNC/HTTP.

## Overview

The chart creates a StatefulSet that:
- Uses a console container image with Phoebus, Java, and Ansible pre-installed
- Fetches an OPI release archive during initialization, or clones a repository when no archive URL is configured
- Runs Ansible playbook to configure the console environment automatically
- Mounts the OPI files and configuration into the running container
- Provides persistent volumes for autosave and data storage

## Image Features

The container image (`ghcr.io/infn-epics/nox-ubuntu-console`) includes:
- **Ubuntu 24.04** LXDE desktop
- **Ansible** - For automated console configuration
- **Git** - For cloning OPI repositories
- **VNC Server** (x11vnc) - Remote desktop access
- **Web-based VNC client** (noVNC) - Browser access on port 80

## How It Works

### Initialization Process

1. **Init Container** (`init-console`):
   - Uses the same image as the main container
   - If `gitRepoConfig.archiveUrl` is set, downloads and extracts that archive to `/phoebus/beamline-repo`; otherwise clones the configured Git repository there
   - For private GitLab release archives, `git_credentials_secret` supplies credentials using the same per-URL-prefix format as ioc-chart
   - Creates data directories

2. **Main Container** (`epics-console`):
   - Runs the Ansible playbook (`ANSIBLE_PLAYBOOK` / `ANSIBLE_DIR`) at startup to configure the console
   - Starts the desktop environment with the specified OPI and settings
   - Runs VNC server for remote access
   - Uses persistent volumes for autosave and data

### Volume Mounts

- `/phoebus` - EmptyDir volume containing the extracted release archive or cloned repository and Phoebus installation
- `/autosave` - Persistent volume for autosave files (PVC)
- `/data` - Persistent volume for data storage (PVC)
- `/phoebus/phoebus_settings.ini` - Optional ConfigMap mount for Phoebus configuration

### Configuration

The chart can be configured via ConfigMap (`epicsConfiguration.name`) which should contain:
- `phoebus_settings.ini` - Phoebus settings file
- Environment variables for EPICS configuration (gateway addresses, etc.)

The `PHOEBUSINI` environment variable is automatically set to point to the mounted settings file.

## Key Environment Variables

- `OPIHOME` - Path to OPI repository (`/phoebus/beamline-repo/opi`)
- `OPIDATA` - Path for runtime data (`/data/opi`)
- `OPISTART` - Startup script to execute
- `OPIMAIN` - Main OPI file to display
- `PHOEBUSINI` - Path to Phoebus settings file
- `EPICS_CA_ADDR_LIST` - EPICS Channel Access gateway addresses
- `EPICS_CA_AUTO_ADDR_LIST` - Set to "NO" when gateway is specified

## Requirements

- Kubernetes cluster or OpenShift
- Git repository containing:
  - OPI files (Phoebus display files)
  - `opi/ansible/` directory with:
    - `localhost.yml` - Ansible inventory for localhost
    - `configure-consoles.yml` or `configure-epics-consoles.yml` - Ansible playbook
    - Console configuration role

## Usage

```yaml
image:
  repository: ghcr.io/infn-epics/nox-ubuntu-console
  tag: latest

gitRepoConfig:
  # Prefer a release archive when the console should run a released OPI snapshot.
  # The archive is fetched at pod initialization; restarting the pod fetches it again.
  archiveUrl: https://gitlab.example.com/group/project/-/releases/permalink/latest/downloads/opi.tar.gz
  url: https://your-git-server.com/your-opi-repo.git
  branch: main
  exec: start.sh

# Optional Secret containing gitconfig and per-URL-prefix credential files.
# git_credentials_secret: epik8s-git-credentials

epicsConfiguration:
  name: my-epics-config
  gateway: "10.0.0.1:5064 10.0.0.2:5064"

opimain: opi/MainDisplay.bob
```

## Access

- **VNC**: Port 5900
- **Web**: Port 80 (HTTP)
- **Ingress/Route**: Configure via `ingress` or `route` values

## Persistent Storage

The chart creates two PersistentVolumeClaims:
- `autosave-volume` - 1Gi for autosave files
- `data-volume` - 1Gi for runtime data

Alternatively, specify existing PVCs:
```yaml
autosaveClaim: my-existing-autosave-pvc
dataClaim: my-existing-data-pvc
```
