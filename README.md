# NONMEM Docker Wrappers

Docker images and thin host scripts for running [NONMEM](https://www.iconplc.com/innovation/nonmem/) with [PsN](https://uupharmacometrics.github.io/PsN/) on **macOS**, **Linux**, and **Windows**. Each NONMEM release has a versioned directory (`nm743`, `nm750`, `nm760`) whose commands invoke `docker run` with your model folder and license mounted into the container.

> **License & use**  
> For personal research only. You must supply your own ICON `nonmem.lic`. Installation media (NONMEM CD / zip) is not included in this repository.

---

## Table of contents

- [Overview](#overview)
- [Supported versions](#supported-versions)
- [Prerequisites](#prerequisites)
- [Quick start](#quick-start)
- [Windows installation](#windows-installation)
- [Building images (developers)](#building-images-developers)
- [Publishing to Docker Hub](#publishing-to-docker-hub)
- [Host wrappers](#host-wrappers)
- [Running models](#running-models)
- [Pirana integration](#pirana-integration)
- [Parallel runs (MPI)](#parallel-runs-mpi)
- [Troubleshooting](#troubleshooting)
- [Related projects](#related-projects)
- [Acknowledgments](#acknowledgments)

---

## Overview

| Concept | Description |
|--------|-------------|
| **Host directory** | `nm743/`, `nm750/`, or `nm760/` — templates become runnable scripts after install |
| **Install (Unix)** | `./install.sh` → shell scripts (`execute`, `util/nmfeXX`, …) |
| **Install (Windows)** | `install.ps1` → PowerShell + `.cmd` launchers (`execute.cmd`, …) |
| **Docker image** | Pre-built `kinginsun/nonmem:<version>` — pull with Docker; no local build needed |
| **Model directory** | Your working directory; mounted as `/nonmem/models` in the container |
| **License** | `license/nonmem.lic` in the host directory, mounted into the container |

Host scripts do not install NONMEM on the host OS. They only wrap Docker. Additional PsN tools can be exposed the same way as `execute` and `nmfeXX` (see `*.dat` templates).

Visual flow:

```
Host:  cd my_project/
       ../nm760/execute mymodel.mod
          │
          ▼
Docker:  mount license + my_project → run NONMEM/PsN inside image
          │
          ▼
Host:  results written in my_project/
```

---

## Supported versions

| NONMEM | Host dir | Image (recommended) | Dockerfile | Base OS | PsN | `nmfe` |
|--------|----------|---------------------|------------|---------|-----|--------|
| 7.4.3 | `nm743/` | `kinginsun/nonmem:7.4.3` | `Dockerfile.7.4.3` | Ubuntu 16.04 | 5.7.1 | `nmfe74` |
| 7.5.0 | `nm750/` | `kinginsun/nonmem:7.5.0` | `Dockerfile.7.5.0` | Ubuntu 18.04 | 5.7.1 | `nmfe75` |
| 7.6.0 | `nm760/` | `kinginsun/nonmem:7.6.0` | `Dockerfile.7.6.0` | Ubuntu 22.04 | 5.7.1 | `nmfe76` |

**7.4.3 alternative (developers):** `Dockerfile` builds a NONMEM-only image without MPI / PsN (not used by host wrappers).

Use `Dockerfile.7.4.3` for Pirana, PsN, and parallel runs.

**Image size:** All Dockerfiles use a multi-stage build and copy only the required CD + `PsN-Source` (not the whole `install/` folder). `7.6.0` is ~**1.1–1.3 GB**; older single-stage layouts that `ADD install/` were ~2.5–3.4 GB.

---

## Prerequisites

| Requirement | macOS / Linux | Windows |
|-------------|---------------|---------|
| [Docker](https://docs.docker.com/get-docker/) | Docker Desktop or Engine | [Docker Desktop for Windows](https://docs.docker.com/desktop/setup/install/windows-install/) |
| [Git](https://git-scm.com/) | Yes | Yes (Git for Windows) |
| ICON `nonmem.lic` | Yes (your license file) | Same |
| ICON NONMEM installation media | Only if [building images locally](#building-images-developers) | Same |
| [Pirana](https://www.certara.com/software/pirana-modeling-workbench/) | Optional (macOS) | Not available (macOS only) |
| XQuartz + `xterm` | Optional (Pirana terminal) | Not required |
| PowerShell | — | 5.1+ (included in Windows 10/11) |

Step-by-step slides (legacy): [how to install nonmem.pptx](https://github.com/kinginsun/nonmem/blob/master/how%20to%20install%20nonmem.pptx)

---

## Quick start

**End users:** pull a pre-built image — no local build or NONMEM CD required.

```bash
git clone https://github.com/kinginsun/nonmem.git
cd nonmem
```

1. **Pull** the Docker image for your NONMEM version:

   ```bash
   docker pull kinginsun/nonmem:7.6.0   # or kinginsun/nonmem:7.5.0 / kinginsun/nonmem:7.4.3
   ```

2. **Install host wrappers** and place your license:

   **macOS / Linux**

   ```bash
   cd nm760   # or nm743 / nm750
   cp /path/to/your/nonmem.lic license/nonmem.lic
   ./install.sh
   ```

   **Windows** — see [Windows installation](#windows-installation).

3. **Run** from the directory that contains your `.mod` file:

   ```bash
   cd /path/to/your/model_directory
   /path/to/nonmem/nm760/execute mymodel.mod
   ```

Host scripts (`execute`, `nmfeXX`, …) call `docker run` with the matching `kinginsun/nonmem:<version>` image. You only need Docker, this repo, and your ICON license file.

---

## Windows installation

On Windows, use **Docker Desktop** with the **Linux container** backend (default). Wrappers are generated as `*.cmd` files (double-click or Command Prompt) backed by `*.ps1` scripts.

### Quick start (Windows)

```powershell
git clone https://github.com/kinginsun/nonmem.git
cd nonmem
```

1. **Pull** the Docker image (PowerShell or cmd in repo root):

   ```powershell
   docker pull kinginsun/nonmem:7.6.0   # or kinginsun/nonmem:7.5.0 / kinginsun/nonmem:7.4.3
   ```

2. **Install host wrappers** for your version:

   ```powershell
   cd nm760
   Copy-Item C:\path\to\your\nonmem.lic license\nonmem.lic
   powershell -ExecutionPolicy Bypass -File .\install.ps1
   ```

   Or right-click `install.ps1` → **Run with PowerShell** (if execution policy allows).

3. Run from the folder that contains your `.mod` file:

   ```cmd
   cd C:\projects\my_model
   C:\path\to\nonmem\nm760\execute.cmd mymodel.mod
   C:\path\to\nonmem\nm760\util\nmfe76.cmd mymodel.mod myoutput
   ```

### Windows notes

| Topic | Guidance |
|-------|----------|
| **Paths** | Install script converts paths to forward slashes for Docker volume mounts. Avoid special characters in project paths if possible. |
| **WSL2** | You may use `./install.sh` inside WSL and treat paths like Linux; keep the repo on the WSL filesystem (`~/...`) for best I/O. |
| **Generated files** | `install.ps1` creates `execute.cmd`, `execute.ps1`, etc. Do not commit them; re-run install after moving the repo. |
| **Uninstall** | `powershell -File uninstall.ps1` removes generated `.cmd` / `.ps1` wrappers. |
| **Skip tests** | `install.ps1 -SkipTests` skips the sample `CONTROL5.mod` run. |
| **MPI on Windows** | Parafiles in `models/` target Linux paths inside the container; use them via `execute.cmd` the same way as on Unix. |

### Add to PATH (optional)

Add the version directory (e.g. `C:\nonmem\nm760`) to your user **Path** environment variable so you can run `execute.cmd` from any model folder.

---

## Building images (developers)

> **For maintainers only.** End users should `docker pull kinginsun/nonmem:<version>` (see [Quick start](#quick-start)). Building requires ICON NONMEM installation media under `install/` (not in git).

Run all `docker build` commands from the **repository root**.

### Install directory layout

The `install/` folder is not committed. Obtain NONMEM from [ICON](https://nonmem.iconplc.com/) and extract as follows:

| Version | Required under `install/` |
|---------|---------------------------|
| 7.4.3 (MPI + PsN) | `nm743CD/`, `PsN-Source/` |
| 7.4.3 (plain) | `nm743CD/`, `PsN-Source/` |
| 7.5.0 | `nm750CD/`, `PsN-Source/` |
| 7.6.0 | `nm760CD/` (must contain `SETUP76`), `PsN-Source/` — details in [`install/README.7.6.0.md`](install/README.7.6.0.md) |

### Build commands

**NONMEM 7.6.0** (recommended layout; smallest image):

```bash
docker build -f Dockerfile.7.6.0 -t kinginsun/nonmem:7.6.0 .
```

**NONMEM 7.5.0:**

```bash
docker build -f Dockerfile.7.5.0 -t kinginsun/nonmem:7.5.0 .
```

**NONMEM 7.4.3:**

```bash
# MPI + PsN (matches nm743/install.sh)
docker build -f Dockerfile.7.4.3 -t kinginsun/nonmem:7.4.3 .

# NONMEM only (no MPI / PsN; not used by host wrappers)
docker build -f Dockerfile -t nonmem:7.4.3-plain .
```

---

## Publishing to Docker Hub

Images are published as **`kinginsun/nonmem:<version>`** on [Docker Hub](https://hub.docker.com/r/kinginsun/nonmem).

### Publish (maintainers)

1. Log in:

   ```bash
   docker login
   ```

2. Build and push one version or all:

   ```bash
   # macOS / Linux
   ./scripts/publish-docker.sh 7.6.0
   ./scripts/publish-docker.sh all

   # Windows (PowerShell)
   .\scripts\publish-docker.ps1 -Version 7.6.0
   .\scripts\publish-docker.ps1 -Version all
   ```

   Push an existing local image without rebuilding:

   ```bash
   ./scripts/publish-docker.sh 7.6.0 --push-only
   ```

3. Confirm tags on Docker Hub: https://hub.docker.com/r/kinginsun/nonmem/tags

| Tag | Dockerfile | Notes |
|-----|------------|--------|
| `7.6.0` | `Dockerfile.7.6.0` | Multi-stage, ~1.1 GB |
| `7.5.0` | `Dockerfile.7.5.0` | Multi-stage; requires `install/nm750CD` + `PsN-Source` |
| `7.4.3` | `Dockerfile.7.4.3` | Multi-stage; requires `install/nm743CD` + `PsN-Source` |

Override the registry name: `DOCKER_REGISTRY=myuser/nonmem ./scripts/publish-docker.sh 7.6.0` (default: `kinginsun/nonmem`)

**License note:** Images contain NONMEM binaries compiled from ICON installation media. Publishing is for licensed users; end users still mount their own `nonmem.lic` at run time.

---

## Host wrappers

Each `nmXXX/` directory contains `*.dat` templates for Unix. On Windows, `install.ps1` generates PowerShell and CMD wrappers via [`scripts/install-windows.ps1`](scripts/install-windows.ps1).

**Unix:** `./install.sh` · **Windows:** `powershell -File install.ps1`

| Script | 7.4.3 | 7.5.0 | 7.6.0 |
|--------|:-----:|:-----:|:-----:|
| `execute` | ✓ | ✓ | ✓ |
| `util/nmfeXX` | `nmfe74` | `nmfe75` | `nmfe76` |
| `vpc`, `bootstrap` | partial | ✓ | ✓ |
| `scm`, `util/ddexpand` | — | ✓ | ✓ |
| `nmshell` | ✓ | ✓ | ✓ |

Example after install in `nm760`:

```bash
# macOS / Linux
cd nm760/models && ../execute CONTROL5.mod
```

```cmd
REM Windows
cd nm760\models
..\execute.cmd CONTROL5.mod
```

Uninstall: `./uninstall.sh` (Unix) or `powershell -File uninstall.ps1` (Windows).

---

## Running models

### Via host wrappers (typical)

```bash
cd /path/to/your/model_directory
/path/to/nonmem/nm750/execute CONTROL5.mod
/path/to/nonmem/nm750/util/nmfe75 CONTROL5.mod OUTPUT5
```

Output files are created in the current directory.

### Direct `docker run` (no `install.sh`)

Adjust `NM_ROOT`, image tag, and in-container paths for your version (`nm750` / `nmfe75` shown):

```bash
NM_ROOT=/path/to/nonmem/nm750
TAG=kinginsun/nonmem:7.5.0
MODEL_DIR=$(pwd)

docker run --rm \
  --workdir /nonmem/models \
  -v "${NM_ROOT}/license:/nonmem/nm750/license" \
  -v "${MODEL_DIR}:/nonmem/models" \
  "${TAG}" execute CONTROL5.mod

docker run --rm \
  --workdir /nonmem/nm750/util \
  -v "${NM_ROOT}/license:/nonmem/nm750/license" \
  -v "${MODEL_DIR}:/nonmem/models" \
  "${TAG}" nmfe75 CONTROL5.mod OUTPUT5 -rundir=/nonmem/models
```

For 7.4.3 / 7.6.0, replace `nm750` and `nmfe75` with `nm743`/`nmfe74` or `nm760`/`nmfe76`.

---

## Pirana integration

1. **PsN executables location** — point to the version directory (e.g. `.../nonmem/nm760`).
2. **NONMEM** — same path; add a named installation (e.g. `nm76`) and let Pirana discover binaries.
3. When running via `nmfeXX`, enable **Copy back results to main folder** so outputs appear in Pirana.
4. Ensure `/usr/local/bin` is on the PATH Pirana uses (see [Troubleshooting](#pirana-does-not-open-a-terminal-macos)).

**Downloads**

- Pirana 2.9.9 (newer macOS): https://s3.amazonaws.com/certara-pirana/pirana_2.9.9_MacOSX.dmg  
- Pirana 2.9.8 (legacy link): https://www.evernote.com/l/ABkzIX34qFxOB6aqA1Sxk3pFat5VLDC0f9E  
- Academic license: contact [Certara](https://www.certara.com/software/pirana-modeling-workbench/)

---

## Parallel runs (MPI)

Use a parafile with `execute` or `nmfeXX`. Each version ships `models/pirana_auto_mpi.pnm` for Linux/Docker:

```bash
cd nm750/models
../execute -parafile=pirana_auto_mpi.pnm CONTROL5.mod -nodes=4
../util/nmfe75 CONTROL5.mod OUTPUT5 "-parafile=pirana_auto_mpi.pnm" "[nodes]=4"
```

Reference parafile (Linux, in-container paths):

```text
$DEFAULTS
[nodes]=4

$GENERAL
NODES=[nodes] PARSE_TYPE=2 TIMEOUTI=20 TIMEOUT=500 PARAPRINT=1 TRANSFER_TYPE=1

$COMMANDS
1:mpirun -wdir "$PWD" -n 1 ./nonmem  $*
2-[nodes]:-wdir "$PWD/worker{#-1}" -n 1 ./nonmem

$DIRECTORIES
1:NONE
2-[nodes]:worker{#-1}
```

**7.4.3 host MPI notes (non-Docker):** The NONMEM 7.4.3 CD includes `mpich2`. Replace `nm743/mpi/mpi_ling/libmpich.a` with the 64-bit library from your mpich2 build; configure `mpd.conf` (mode `600`). Docker images already bundle MPI. Auto-FPI across multiple hosts is not documented here.

---

## Troubleshooting

### Windows: Docker volume or path errors

- Enable **File sharing** for your drive in Docker Desktop → **Settings → Resources → File sharing**.
- Prefer paths under your user profile (e.g. `C:\Users\you\projects`) rather than network drives.
- Re-run `install.ps1` after moving the repository so embedded paths stay correct.

### Windows: script execution disabled

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
# or invoke once:
powershell -ExecutionPolicy Bypass -File .\install.ps1
```

### Pirana does not open a terminal (macOS)

After macOS upgrades, `/usr/bin/xterm` may be missing. Terminal runs of `execute` / PsN work, but Pirana fails to spawn a window.

```bash
which xterm
sudo ln -sf /opt/X11/bin/xterm /usr/local/bin/xterm
```

In Pirana: **Settings → Software integration → Other Terminal**, and add `/usr/local/bin` to the PATH (Environment variables → Add to PATH by Pirana).

### Pirana does not show run results

Enable **Copy back results to main folder** when using `nmfe74`, `nmfe75`, or `nmfe76`.

### Docker build fails on PsN / `psn.conf` (7.6.0)

Use the current `Dockerfile.7.6.0`. PsN installs under `/usr/local/share/perl/<version>/PsN_5_7_1/`, not Debian’s `archlib` path.

### Image still large (7.6.0)

Rebuild with the multi-stage `Dockerfile.7.6.0` (selective `COPY`, not `ADD install/`). Do not keep old layers tagged as `7.6.0` without rebuilding.

---

## Related projects

- [kinginsun/nonmem](https://github.com/kinginsun/nonmem) — this repository  
- [Pharmacometrics-Docker](https://github.com/billdenney/Pharmacometrics-Docker) — alternative NONMEM Docker builds  

---

## Acknowledgments

- [PsN](https://uupharmacometrics.github.io/PsN/docs.html) · [Download](https://uupharmacometrics.github.io/PsN/download.html)  
- [ICON NONMEM](https://www.iconplc.com/innovation/nonmem/) · [Download](https://nonmem.iconplc.com/)  
- [Pirana](https://www.certara.com/software/pirana-modeling-workbench/)  
