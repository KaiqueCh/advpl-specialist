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
