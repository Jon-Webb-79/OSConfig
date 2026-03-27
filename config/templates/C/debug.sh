#!/usr/bin/bash
set -euo pipefail

# ------------------------------------------------------------
# Debug builder for prjct_name tests
# - Builds Debug with PRJCT_NAME_BUILD_TESTS=ON
# - Produces: build/debug/bin/unit_tests
# - Runs unit_tests (use --no-run to skip)
#
# Usage:
#   ./scripts/unix/debug.sh
#   ./scripts/unix/debug.sh --no-run
#   ./scripts/unix/debug.sh --clean
#   ./scripts/unix/debug.sh --generator "Unix Makefiles"
# ------------------------------------------------------------

BUILD_DIR="build/debug"
BUILD_TYPE="Debug"
RUN_AFTER_BUILD=1
GEN="${CMAKE_GENERATOR:-}"
CLEAN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-run) RUN_AFTER_BUILD=0; shift ;;
    --clean)  CLEAN=1; shift ;;
    --generator)
      [[ $# -ge 2 ]] || { echo "Missing value for --generator" >&2; exit 1; }
      GEN="$2"; shift 2 ;;
    -h|--help)
      echo "Usage: $0 [--no-run] [--clean] [--generator NAME]"
      exit 0
      ;;
    *) echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
PROJ_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SRC_DIR="$PROJ_ROOT/prjct_name"
OUT_DIR="$PROJ_ROOT/$BUILD_DIR"
BIN_DIR="$OUT_DIR/bin"
UNIT_EXE="$BIN_DIR/unit_tests"

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
  -DBUILD_SHARED_LIBS=ON
  -DPRJCT_NAME_BUILD_TESTS=ON
)
[[ -n "$GEN" ]] && CMAKE_ARGS+=(-G "$GEN")

cmake "${CMAKE_ARGS[@]}"
cmake --build "$OUT_DIR" --config "$BUILD_TYPE" --target unit_tests -- -j "$JOBS"

if [[ -x "$UNIT_EXE" ]]; then
  echo "==> Built: $UNIT_EXE"
else
  FOUND=$(find "$OUT_DIR" -type f -name unit_tests -perm -u+x 2>/dev/null | head -n1 || true)
  if [[ -n "$FOUND" ]]; then
    UNIT_EXE="$FOUND"
    echo "==> Built: $UNIT_EXE"
  else
    echo "ERROR: unit_tests executable not found." >&2
    exit 2
  fi
fi

if [[ "$RUN_AFTER_BUILD" -eq 1 ]]; then
  echo "==> Running unit_tests"
  "$UNIT_EXE"
fi

echo "==> Done. You can run later via: $UNIT_EXE"

