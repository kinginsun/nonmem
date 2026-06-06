# kinginsun/nonmem

**Docker Hub short description (one line):**

> NONMEM 7.4.3 / 7.5.0 / 7.6.0 + PsN 5.7.1 + MPI (MPICH). Host wrappers: [github.com/kinginsun/nonmem](https://github.com/kinginsun/nonmem)

Docker images for [NONMEM](https://www.iconplc.com/innovation/nonmem/) with **[PsN](https://uupharmacometrics.github.io/PsN/)** and **MPI (MPICH)** built in. Each tag is a ready-to-run environment; pair it with the host wrapper scripts in the [GitHub repository](https://github.com/kinginsun/nonmem).

> Personal / research use only. You must supply your own ICON `nonmem.lic`. NONMEM installation media is **not** included in the image or on GitHub.

---

## Available tags

| Tag | NONMEM | PsN | MPI | Base OS | Typical size |
|-----|--------|-----|-----|---------|--------------|
| `7.4.3` | 7.4.3 | 5.7.1 | MPICH | Ubuntu 16.04 | ~900 MB |
| `7.5.0` | 7.5.0 | 5.7.1 | MPICH | Ubuntu 18.04 | ~910 MB |
| `7.6.0` | 7.6.0 | 5.7.1 | MPICH | Ubuntu 22.04 | ~1.2 GB |

**Every image includes:**

- **PsN** — `execute`, `vpc`, `bootstrap`, `scm` (7.5.0+), and related tooling
- **MPI** — MPICH + `mpif90` / dev libraries for parallel NONMEM builds at run time (`-parafile=…`, `[nodes]=…`)
- **`nmfeXX`** — Fortran compile-and-run helper (`nmfe74` / `nmfe75` / `nmfe76`)

`7.4.3` and `7.5.0` are **`linux/amd64`** images. On Apple Silicon, Docker runs them under emulation; host wrappers pass `--platform linux/amd64` automatically. `7.6.0` also runs natively on **arm64**.

---

## Quick start

```bash
docker pull kinginsun/nonmem:7.6.0   # or :7.5.0 / :7.4.3

git clone https://github.com/kinginsun/nonmem.git
cd nonmem/nm760                    # or nm743 / nm750
cp /path/to/your/nonmem.lic license/nonmem.lic
./install.sh                       # macOS / Linux; Windows: install.ps1
```

Run from your model directory:

```bash
cd /path/to/your/models
/path/to/nonmem/nm760/execute mymodel.mod
/path/to/nonmem/nm760/util/nmfe76 mymodel.mod myoutput
```

**MPI example:**

```bash
/path/to/nonmem/nm760/execute -parafile=pirana_auto_mpi.pnm mymodel.mod -nodes=4
/path/to/nonmem/nm760/util/nmfe76 mymodel.mod myoutput_mpi \
  "-parafile=pirana_auto_mpi.pnm" "[nodes]=4"
```

Sample parafile: `nm760/models/pirana_auto_mpi.pnm` (same layout for `nm743` / `nm750`).

---

## Host wrappers (GitHub)

Images alone do not install commands on your OS. The repo generates thin scripts that call `docker run` with your **license** and **model folder** mounted:

| NONMEM | Host directory | Image |
|--------|----------------|-------|
| 7.4.3 | `nm743/` | `kinginsun/nonmem:7.4.3` |
| 7.5.0 | `nm750/` | `kinginsun/nonmem:7.5.0` |
| 7.6.0 | `nm760/` | `kinginsun/nonmem:7.6.0` |

Supported hosts: **macOS**, **Linux**, **Windows** (Docker Desktop, Linux containers).

---

## Pirana

Point Pirana’s NONMEM / PsN paths to the matching host directory (e.g. `…/nonmem/nm743` for 7.4.3). Wrappers keep runs inside Docker without touching a system-wide NONMEM install.

---

## Build from source (maintainers)

```bash
git clone https://github.com/kinginsun/nonmem.git
cd nonmem
# Place ICON media under install/ — see README
docker build --platform linux/amd64 -f Dockerfile.7.4.3 -t kinginsun/nonmem:7.4.3 .
docker build --platform linux/amd64 -f Dockerfile.7.5.0 -t kinginsun/nonmem:7.5.0 .
docker build -f Dockerfile.7.6.0 -t kinginsun/nonmem:7.6.0 .
```

---

## Links

- **GitHub:** [kinginsun/nonmem](https://github.com/kinginsun/nonmem)
- **PsN:** [Documentation](https://uupharmacometrics.github.io/PsN/docs.html) · [Download](https://uupharmacometrics.github.io/PsN/download.html)
- **NONMEM:** [ICON](https://www.iconplc.com/innovation/nonmem/) · [Download](https://nonmem.iconplc.com/)
- **Pirana:** [Certara](https://www.certara.com/software/pirana-modeling-workbench/)
