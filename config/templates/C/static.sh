#!/usr/bin/bash
set -euo pipefail

# ------------------------------------------------------------
# Install static prjct_name library (tests OFF)
# - Default prefix: /usr/local
# - Default build type: Release
# - Builds prjct_name as STATIC via BUILD_SHARED_LIBS=OFF
# - Elevates only for the install step if needed
#
# Usage:
#   ./scripts/unix/static.sh
#   ./scripts/unix/static.sh --prefix /opt/prjct_name
#   ./scripts/unix/static.sh --relwithdebinfo
#   ./scripts/unix/static.sh --generator "Unix Makefiles"
#   ./scripts/unix/static.sh --clean
# ------------------------------------------------------------

PREFIX="${CMAKE_INSTALL_PREFIX:-/usr/local}"
BUILD_DIR="build/static"
BUILD_TYPE="Release"
GEN="${CMAKE_GENERATOR:-}"
CLEAN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --prefix)
      [[ $# -ge 2 ]] || { echo "Missing value for --prefix" >&2; exit 1; }
      PREFIX="$2"; shift 2 ;;
    --release)       BUILD_TYPE="Release"; shift ;;
    --relwithdebinfo|--rel) BUILD_TYPE="RelWithDebInfo"; shift ;;
    --debug)         BUILD_TYPE="Debug"; shift ;;
    --generator)
      [[ $# -ge 2 ]] || { echo "Missing value for --generator" >&2; exit 1; }
      GEN="$2"; shift 2 ;;
    --clean)         CLEAN=1; shift ;;
    -h|--help)
      echo "Usage: $0 [--prefix DIR] [--release|--relwithdebinfo|--debug] [--generator NAME] [--clean]"
      exit 0 ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJ_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SRC_DIR="$PROJ_ROOT/prjct_name"
OUT_DIR="$PROJ_ROOT/$BUILD_DIR"

if command -v nproc >/dev/null 2>&1; then
  JOBS=$(nproc)
elif command -v sysctl >/dev/null 2>&1; then
  JOBS=$(sysctl -n hw.ncpu)
else
  JOBS=4
fi

if [[ -z "$GEN" ]] && command -v ninja >/dev/null 2>&1; then
  GEN="Ninja"
fi

echo "==> Source: $SRC_DIR"
echo "==> Build:  $OUT_DIR ($BUILD_TYPE)"
echo "==> Prefix: $PREFIX"
echo "==> Gen:    ${GEN:-<auto>}"
echo "==> Jobs:   $JOBS"

if [[ "$CLEAN" -eq 1 ]]; then
  rm -rf "$OUT_DIR"
fi
mkdir -p "$OUT_DIR"

CMAKE_ARGS=(
  -S "$SRC_DIR"
  -B "$OUT_DIR"
  -DCMAKE_BUILD_TYPE="$BUILD_TYPE"
  -DCMAKE_INSTALL_PREFIX="$PREFIX"
  -DBUILD_SHARED_LIBS=OFF
  -DPRJCT_NAME_BUILD_TESTS=OFF
  -DPRJCT_NAME_BUILD_STATIC=OFF
)
[[ -n "$GEN" ]] && CMAKE_ARGS+=(-G "$GEN")

cmake "${CMAKE_ARGS[@]}"
cmake --build "$OUT_DIR" --config "$BUILD_TYPE" -- -j "$JOBS"

if [[ -w "$PREFIX" ]]; then
  cmake --install "$OUT_DIR" --config "$BUILD_TYPE"
else
  echo "==> Installing with sudo into $PREFIX"
  sudo cmake --install "$OUT_DIR" --config "$BUILD_TYPE"
fi

echo "==> Static install complete."
echo "    Headers: $PREFIX/include/prjct_name/*.h"
echo "    Library: $PREFIX/lib/libprjct_name.a"

