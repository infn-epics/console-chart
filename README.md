# Epics Console Chart

This Helm chart deploys an EPICS console with Phoebus installed that can be accessed via VNC/HTTP.

## Overview

The chart creates a StatefulSet that:
- Uses a console container image with Phoebus, Java, and Ansible pre-installed
- Clones an OPI (Operator Interface) repository during initialization
- Runs Ansible playbook to configure the console environment automatically
- Mounts the OPI files and configuration into the running container
- Provides persistent volumes for autosave and data storage

## Image Features

The container image (`baltig.infn.it:4567/epics-containers/epics-docker-console`) includes:
- **Phoebus** - CS-Studio replacement for EPICS control systems
- **Java** (OpenJDK) - Required runtime for Phoebus
- **Ansible** - For automated console configuration
- **Git** - For cloning OPI repositories
- **VNC Server** - Remote desktop access
- **Web-based VNC client** - Browser access on port 80

## How It Works

### Initialization Process

1. **Init Container** (`init-console`):
   - Uses the same image as the main container
   - Clones the specified OPI git repository to `/phoebus/beamline-repo`
   - Navigates to `opi/ansible/` directory
   - Executes Ansible playbook (`ansible-playbook -i localhost.yml configure-consoles.yml`)
   - Creates data directories

2. **Main Container** (`epics-console`):
   - Accesses the pre-configured environment
   - Starts Phoebus with the specified OPI and settings
   - Runs VNC server for remote access
   - Uses persistent volumes for autosave and data

### Volume Mounts

- `/phoebus` - EmptyDir volume containing cloned repository and Phoebus installation
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
  repository: baltig.infn.it:4567/epics-containers/epics-docker-console
  tag: latest

gitRepoConfig:
  url: https://your-git-server.com/your-opi-repo.git
  branch: main
  exec: start.sh

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
