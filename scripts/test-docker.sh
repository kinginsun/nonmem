#!/usr/bin/env bash
# Build (optional) and smoke-test kinginsun/nonmem images.
# Usage:
#   ./scripts/test-docker.sh              # test existing images
#   ./scripts/test-docker.sh --build      # rebuild then test
#   ./scripts/test-docker.sh --build 7.6.0   # one version only

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD=0
TARGET="all"

usage() {
    echo "Usage: $(basename "$0") [--build] [7.4.3|7.5.0|7.6.0|all]"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --build) BUILD=1 ;;
        7.4.3|7.5.0|7.6.0|all) TARGET="$1" ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown: $1" >&2; usage; exit 1 ;;
    esac
    shift
done

build_one() {
    local ver="$1"
    local df="$REPO_ROOT/Dockerfile.${ver}"
    local tag="kinginsun/nonmem:${ver}"
    echo "======== BUILD $tag ========"
    local platform_args=()
    case "$ver" in
        7.4.3|7.5.0) platform_args=(--platform linux/amd64) ;;
    esac
    docker build "${platform_args[@]}" -f "$df" -t "$tag" "$REPO_ROOT"
}

test_one() {
    local ver="$1"
    local nm_dir="$2"
    local nmfe="$3"
    local tag="kinginsun/nonmem:${ver}"
    local license="${REPO_ROOT}/${nm_dir}/license"
    local models="${REPO_ROOT}/${nm_dir}/models"
    local platform_args=()
    case "$ver" in
        7.4.3|7.5.0) platform_args=(--platform linux/amd64) ;;
    esac

    if [[ ! -f "${license}/nonmem.lic" ]]; then
        echo "SKIP $tag: missing ${license}/nonmem.lic"
        return 1
    fi

    echo "======== TEST $tag: execute ========"
    docker run "${platform_args[@]}" --rm \
        --workdir /nonmem/models \
        -v "${license}:/nonmem/${nm_dir}/license" \
        -v "${models}:/nonmem/models" \
        "$tag" execute CONTROL5.mod

    # Stale temp_dir from a host-side nmfe run can leave wrong-arch .o files on the mount.
    rm -rf "${models}/temp_dir"

    echo "======== TEST $tag: $nmfe ========"
    docker run "${platform_args[@]}" --rm \
        --workdir "/nonmem/${nm_dir}/util" \
        -v "${license}:/nonmem/${nm_dir}/license" \
        -v "${models}:/nonmem/models" \
        "$tag" "$nmfe" CONTROL5.mod "OUTPUT5_${ver}" -rundir=/nonmem/models

    echo "PASS $tag"
}

run_version() {
    local ver="$1"
    local nm_dir nmfe
    case "$ver" in
        7.4.3) nm_dir=nm743; nmfe=nmfe74 ;;
        7.5.0) nm_dir=nm750; nmfe=nmfe75 ;;
        7.6.0) nm_dir=nm760; nmfe=nmfe76 ;;
    esac
    if [[ "$BUILD" -eq 1 ]]; then
        build_one "$ver"
    fi
    test_one "$ver" "$nm_dir" "$nmfe"
}

cd "$REPO_ROOT"
docker info >/dev/null

case "$TARGET" in
    all)
        run_version 7.6.0
        run_version 7.5.0
        run_version 7.4.3
        ;;
    *)
        run_version "$TARGET"
        ;;
esac

echo ""
echo "All requested tests passed."
