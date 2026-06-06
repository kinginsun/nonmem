#!/usr/bin/env bash
# Build and push NONMEM Docker images (default tag: nonmem:<version>).
#
# Usage:
#   ./scripts/publish-docker.sh 7.6.0
#   ./scripts/publish-docker.sh all
#   ./scripts/publish-docker.sh 7.6.0 --push-only
#
# Prerequisites:
#   - docker login   (Docker Hub account with push access to the nonmem repository)
#   - install/ media for the version(s) you build (see README)

set -euo pipefail

REGISTRY="${DOCKER_REGISTRY:-kinginsun/nonmem}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PUSH_ONLY=0

usage() {
    cat <<EOF
Usage: $(basename "$0") <7.4.3|7.5.0|7.6.0|all> [--push-only]

  7.4.3   Build Dockerfile.7.4.3 and push ${REGISTRY}:7.4.3
  7.5.0   Build Dockerfile.7.5.0 and push ${REGISTRY}:7.5.0
  7.6.0   Build Dockerfile.7.6.0 and push ${REGISTRY}:7.6.0
  all     Build and push all three MPI images

  --push-only   Skip build; push an image that already exists locally

Environment:
  DOCKER_REGISTRY   Override image name (default: kinginsun/nonmem)

Examples:
  docker login
  ./scripts/publish-docker.sh 7.6.0
  ./scripts/publish-docker.sh all --push-only
EOF
}

build_image() {
    local version="$1"
    local dockerfile tag
    case "$version" in
        7.4.3)
            dockerfile="Dockerfile.7.4.3"
            tag="${REGISTRY}:7.4.3"
            ;;
        7.5.0)
            dockerfile="Dockerfile.7.5.0"
            tag="${REGISTRY}:7.5.0"
            ;;
        7.6.0)
            dockerfile="Dockerfile.7.6.0"
            tag="${REGISTRY}:7.6.0"
            ;;
        *)
            echo "Unknown version: $version" >&2
            exit 1
            ;;
    esac

    if [[ "$PUSH_ONLY" -eq 0 ]]; then
        echo "==> Building $tag ($dockerfile)"
        docker build -f "$REPO_ROOT/$dockerfile" -t "$tag" "$REPO_ROOT"
    else
        echo "==> Skipping build (--push-only)"
    fi

    if ! docker image inspect "$tag" >/dev/null 2>&1; then
        echo "Image not found locally: $tag" >&2
        exit 1
    fi

    echo "==> Pushing $tag"
    docker push "$tag"
    echo "==> Published $tag"
}

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

TARGET="$1"
shift

while [[ $# -gt 0 ]]; do
    case "$1" in
        --push-only) PUSH_ONLY=1 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
    esac
    shift
done

cd "$REPO_ROOT"

if ! docker info >/dev/null 2>&1; then
    echo "Docker is not running." >&2
    exit 1
fi

case "$TARGET" in
    7.4.3|7.5.0|7.6.0)
        build_image "$TARGET"
        ;;
    all)
        build_image 7.4.3
        build_image 7.5.0
        build_image 7.6.0
        ;;
    -h|--help)
        usage
        ;;
    *)
        echo "Unknown target: $TARGET" >&2
        usage
        exit 1
        ;;
esac

echo "Done."
