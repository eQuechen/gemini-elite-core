#!/usr/bin/env bash

set -euo pipefail

# Elite Committer for Gemini Elite Core
# Inspired by clawdbot - ensures atomic and safe commits.

usage() {
  printf 'Usage: %s "commit message" "file" ["file" ...]\n' "$(basename "$0")" >&2
  exit 2
}

if [ "$#" -lt 2 ]; then
  usage
fi

commit_message=$1
shift
files=("$@")

# 1. Guardrail: No staging masivo con "."
for file in "${files[@]}"; do
  if [ "$file" = "." ]; then
    printf 'Error: El uso de "." no está permitido para evitar staging masivo. Lista los archivos específicos.\n' >&2
    exit 1
  fi
done

# 2. Guardrail: No commitear archivos prohibidos o temporales
for file in "${files[@]}"; do
  case "$file" in
    *node_modules* | */node_modules | */node_modules/* | node_modules)
      printf 'Error: No puedes commitear archivos de node_modules: %s\n' "$file" >&2
      exit 1
      ;;
    *.env* | */.env*)
      printf 'Error: No puedes commitear archivos de entorno (.env): %s\n' "$file" >&2
      exit 1
      ;;
    *tsconfig.tsbuildinfo* | */tsconfig.tsbuildinfo)
      printf 'Error: No puedes commitear archivos de build de TS: %s\n' "$file" >&2
      exit 1
      ;;
    *.gemini-clipboard* | */.gemini-clipboard*)
      printf 'Error: No puedes commitear el clipboard de Gemini: %s\n' "$file" >&2
      exit 1
      ;;
  esac
done

# 3. Limpiar staging previo para asegurar atomicidad
git restore --staged :/

# 4. Añadir archivos específicos (usando --force por si están en gitignore pero son necesarios, como algunos assets)
git add -- "${files[@]}"

# 5. Verificar que hay cambios reales
if git diff --staged --quiet; then
  printf 'Error: No hay cambios detectados en los archivos especificados.\n' >&2
  exit 1
fi

# 6. Ejecutar commit
if git commit -m "$commit_message"; then
  printf '✅ Commit exitoso: "%s" (%d archivos)\n' "$commit_message" "${#files[@]}"
else
  printf '❌ Error al ejecutar el commit.\n' >&2
  exit 1
fi
