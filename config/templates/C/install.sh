#!/usr/bin/bash
set -euo pipefail

# ------------------------------------------------------------
# Install shared prjct_name library (tests OFF)
# - Default prefix: /usr/local
# - Default build type: Release
# - Uses Ninja if available
# - Elevates only for the install step if needed
#
# Usage:
#   ./scripts/unix/install.sh
#   ./scripts/unix/install.sh --prefix /opt/prjct_name
#   ./scripts/unix/install.sh --relwithdebinfo
#   ./scripts/unix/install.sh --generator "Unix Makefiles"
#   ./scripts/unix/install.sh --clean
# ------------------------------------------------------------

PREFIX="${CMAKE_INSTALL_PREFIX:-/usr/local}"
BUILD_DIR="build/install"
BUILD_TYPE="Release"
GEN="${CMAKE_GENERATOR:-}"
RUN_LDCONFIG=1
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
    --no-ldconfig)   RUN_LDCONFIG=0; shift ;;
    -h|--help)
      echo "Usage: $0 [--prefix DIR] [--release|--relwithdebinfo|--debug] [--generator NAME] [--clean] [--no-ldconfig]"
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
  -DBUILD_SHARED_LIBS=ON
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

if [[ "$RUN_LDCONFIG" -eq 1 && "$OSTYPE" == linux-gnu* ]]; then
  if [[ $EUID -ne 0 ]]; then
    echo "==> Running ldconfig (sudo)"
    sudo ldconfig
  else
    ldconfig
  fi
fi

echo "==> Install complete."
echo "    Headers: $PREFIX/include/prjct_name/*.h"
echo "    Library: $PREFIX/lib/libprjct_name.so"

