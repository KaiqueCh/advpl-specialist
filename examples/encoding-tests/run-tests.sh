#!/usr/bin/env bash
# Fixture-based runner for hooks/lib/convert-encoding.sh
# Usage: bash examples/encoding-tests/run-tests.sh

set -u

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB="$PLUGIN_ROOT/hooks/lib/convert-encoding.sh"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

PASS=0; FAIL=0
fail() { echo "  ✗ $1"; FAIL=$((FAIL+1)); }
pass() { echo "  ✓ $1"; PASS=$((PASS+1)); }

run_case() {
  local name="$1" fixture="$2" expected="$3"
  echo "[$name]"
  local tmp="$TMP_DIR/$(basename "$fixture")"
  cp "$FIXTURES_DIR/$fixture" "$tmp"
  bash "$LIB" process_file "$tmp" 2>/tmp/err.log
  local actual_encoding
  actual_encoding=$(file -bi "$tmp" | sed -n 's/.*charset=\([^[:space:]]*\).*/\1/p')
  if [ "$actual_encoding" = "$expected" ]; then
    pass "$name → $actual_encoding"
  else
    fail "$name expected=$expected actual=$actual_encoding"
    cat /tmp/err.log >&2
  fi
}

# Cases will be added in Task 7
echo "Test runner ready. PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
