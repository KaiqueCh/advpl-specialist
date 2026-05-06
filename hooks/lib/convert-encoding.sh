#!/usr/bin/env bash
# advpl-specialist — UTF-8 → CP1252 encoding library
# Public functions: is_advpl_file, is_utf8, strip_bom, convert_to_cp1252, process_file

ADVPL_EXTENSIONS_REGEX='\.(prw|tlpp|prx|ch|prg|apw|aph|tlh)$'

is_advpl_file() {
  local path="$1"
  local lower
  lower="$(printf '%s' "$path" | tr '[:upper:]' '[:lower:]')"
  [[ "$lower" =~ $ADVPL_EXTENSIONS_REGEX ]]
}

is_utf8() {
  local path="$1"
  [ -f "$path" ] || return 1
  iconv -f UTF-8 -t UTF-8 < "$path" > /dev/null 2>&1
}

strip_bom() {
  local path="$1"
  [ -f "$path" ] || return 1
  # BOM UTF-8 = EF BB BF (3 bytes)
  local first3
  first3=$(head -c 3 "$path" | od -An -tx1 | tr -d ' \n')
  if [ "$first3" = "efbbbf" ]; then
    local tmp="$path.tmp.$$"
    tail -c +4 "$path" > "$tmp" && mv "$tmp" "$path"
  fi
}

convert_to_cp1252() {
  local path="$1"
  [ -f "$path" ] || return 1
  local tmp="$path.tmp.$$"
  if iconv -f UTF-8 -t WINDOWS-1252//TRANSLIT "$path" > "$tmp" 2>/dev/null; then
    mv "$tmp" "$path"
    return 0
  fi
  rm -f "$tmp"
  echo "advpl-specialist: cannot convert (incompatible chars): $path" >&2
  return 1
}

_check_iconv() {
  if ! command -v iconv >/dev/null 2>&1; then
    if [ "${ADVPL_ENCODING_WARNED:-0}" != "1" ]; then
      echo "advpl-specialist: 'iconv' not found in PATH; encoding conversion disabled" >&2
      export ADVPL_ENCODING_WARNED=1
    fi
    return 1
  fi
  return 0
}

process_file() {
  local path="$1"
  [ -f "$path" ] || return 0
  is_advpl_file "$path" || return 0
  _check_iconv || return 0
  is_utf8 "$path" || return 0
  strip_bom "$path"
  convert_to_cp1252 "$path"
}

# Allow standalone invocation: bash convert-encoding.sh <function> <args...>
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
  fn="${1:-}"
  shift || true
  if declare -F "$fn" >/dev/null; then
    "$fn" "$@"
  else
    echo "unknown function: $fn" >&2
    echo "available: is_advpl_file is_utf8 strip_bom convert_to_cp1252 process_file" >&2
    exit 2
  fi
fi
