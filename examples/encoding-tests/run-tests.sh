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

# Portable charset detection: tries `file -bI` (BSD/macOS) then `file -bi` (GNU/Linux)
detect_charset() {
  local f="$1" out
  out=$(file -bI "$f" 2>/dev/null) || out=""
  if ! echo "$out" | grep -q 'charset='; then
    out=$(file -bi "$f" 2>/dev/null) || out=""
  fi
  echo "$out" | sed -n 's/.*charset=\([^[:space:];]*\).*/\1/p'
}

run_case() {
  local name="$1" fixture="$2" expected="$3"
  echo "[$name]"
  local tmp="$TMP_DIR/$(basename "$fixture")"
  cp "$FIXTURES_DIR/$fixture" "$tmp"
  bash "$LIB" process_file "$tmp" 2>/tmp/err.log
  local actual_encoding
  actual_encoding=$(detect_charset "$tmp")
  if [ "$actual_encoding" = "$expected" ]; then
    pass "$name → $actual_encoding"
  else
    fail "$name expected=$expected actual=$actual_encoding"
    cat /tmp/err.log >&2
  fi
}

assert_extension() {
  local label="$1" path="$2" expected="$3"
  bash "$LIB" is_advpl_file "$path"
  local rc=$?
  if [ "$rc" = "$expected" ]; then pass "extension: $label"; else fail "extension: $label rc=$rc expected=$expected"; fi
}

# Extension filter unit tests
assert_extension "MATA461.prw"      "MATA461.prw"      0
assert_extension "lower.tlpp"       "Service.tlpp"     0
assert_extension "uppercase .PRW"   "FOO.PRW"          0
assert_extension "include .ch"      "include.ch"       0
assert_extension "rejects .txt"     "readme.txt"       1
assert_extension "rejects no-ext"   "Makefile"         1

assert_utf8() {
  local label="$1" fixture="$2" expected="$3"
  bash "$LIB" is_utf8 "$FIXTURES_DIR/$fixture"
  local rc=$?
  if [ "$rc" = "$expected" ]; then pass "is_utf8: $label"; else fail "is_utf8: $label rc=$rc expected=$expected"; fi
}

assert_utf8 "utf8 with acentos"   "utf8-acentos.txt"   0
assert_utf8 "cp1252 with acentos" "cp1252-acentos.txt" 1
assert_utf8 "pure ascii"          "ascii-puro.txt"     0

assert_bom_stripped() {
  local fixture="$1"
  local tmp="$TMP_DIR/strip-$(basename "$fixture")"
  cp "$FIXTURES_DIR/$fixture" "$tmp"
  bash "$LIB" strip_bom "$tmp"
  local first3
  first3=$(head -c 3 "$tmp" | od -An -tx1 | tr -d ' \n')
  if [ "$first3" != "efbbbf" ]; then pass "strip_bom: removed from $fixture"; else fail "strip_bom: BOM still present in $fixture"; fi
}

assert_bom_stripped "utf8-bom.txt"

assert_converts_to_cp1252() {
  local label="$1" fixture="$2"
  local tmp="$TMP_DIR/conv-$(basename "$fixture")"
  cp "$FIXTURES_DIR/$fixture" "$tmp"
  bash "$LIB" convert_to_cp1252 "$tmp" 2>/dev/null
  local rc=$?
  if [ "$rc" = 0 ]; then
    local enc
    enc=$(detect_charset "$tmp")
    if [ "$enc" = "iso-8859-1" ] || [ "$enc" = "us-ascii" ]; then
      pass "convert: $label → $enc"
    else
      fail "convert: $label encoding=$enc"
    fi
  else
    fail "convert: $label rc=$rc"
  fi
}

assert_convert_fails() {
  local label="$1" fixture="$2"
  local tmp="$TMP_DIR/conv-fail-$(basename "$fixture")"
  cp "$FIXTURES_DIR/$fixture" "$tmp"
  bash "$LIB" convert_to_cp1252 "$tmp" 2>/dev/null
  local rc=$?
  if [ "$rc" != 0 ]; then pass "convert: $label correctly failed"; else fail "convert: $label should have failed"; fi
}

assert_converts_to_cp1252 "acentos PT-BR"  "utf8-acentos.txt"
assert_converts_to_cp1252 "ascii puro"     "ascii-puro.txt"
assert_convert_fails      "incompatible"   "utf8-emoji.txt"

assert_idempotent() {
  local fixture="$1"
  local tmp="$TMP_DIR/idemp-$(basename "$fixture")"
  cp "$FIXTURES_DIR/$fixture" "$tmp"
  bash "$LIB" process_file "$tmp"
  local hash1; hash1=$(shasum "$tmp" | awk '{print $1}')
  bash "$LIB" process_file "$tmp"
  local hash2; hash2=$(shasum "$tmp" | awk '{print $1}')
  if [ "$hash1" = "$hash2" ]; then pass "idempotent: $fixture"; else fail "idempotent: $fixture changed on 2nd run"; fi
}

assert_idempotent "utf8-acentos.txt"
assert_idempotent "cp1252-acentos.txt"
assert_idempotent "ascii-puro.txt"

# Cases will be added in Task 7
echo "Test runner ready. PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
