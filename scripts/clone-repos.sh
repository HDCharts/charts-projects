#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST_DIR="$ROOT_DIR/projects"
USE_SSH=0
CLONE_ALL=0
LIST_ONLY=0
DRY_RUN=0

REPO_NAMES=(
  "charts"
  "charts-docs"
  "charts-playground"
  "charts-gif-recorder"
  "charts-github-profile"
)

REPO_LABELS=(
  "HDCharts core library"
  "Documentation site"
  "Playground app"
  "GIF recorder"
  "GitHub organization profile and defaults"
)

REPO_URLS=(
  "https://github.com/HDCharts/charts.git"
  "https://github.com/HDCharts/charts-docs.git"
  "https://github.com/HDCharts/charts-playground.git"
  "https://github.com/hdcodedev/compose-gif-recorder.git"
  "https://github.com/HDCharts/.github.git"
)

usage() {
  cat <<EOF
Usage: scripts/clone-repos.sh [options]

Clone selected HDCharts project repositories into ./projects.

Options:
  --all              Clone all repositories without prompting.
  --dest DIR         Clone repositories into DIR instead of ./projects.
  --dry-run          Print what would be cloned without cloning.
  --ssh              Use SSH clone URLs instead of HTTPS.
  --list             Print configured repositories and exit.
  -h, --help         Show this help.

Examples:
  scripts/clone-repos.sh
  scripts/clone-repos.sh --all
  scripts/clone-repos.sh --ssh --dest ../HDCharts-workspace
EOF
}

to_ssh_url() {
  local url="$1"
  local path

  path="${url#https://github.com/}"
  path="${path%.git}"
  printf 'git@github.com:%s.git\n' "$path"
}

repo_url_at() {
  local index="$1"
  local url="${REPO_URLS[$index]}"

  if [[ "$USE_SSH" -eq 1 ]]; then
    to_ssh_url "$url"
  else
    printf '%s\n' "$url"
  fi
}

print_repos() {
  local i

  for i in "${!REPO_NAMES[@]}"; do
    printf '%d. %-20s %s\n' "$((i + 1))" "${REPO_NAMES[$i]}" "${REPO_LABELS[$i]}"
  done
}

parse_selection() {
  local input="$1"
  local token
  local index
  local selected=()

  input="${input//,/ }"

  for token in $input; do
    token="$(printf '%s' "$token" | tr '[:upper:]' '[:lower:]')"

    if [[ "$token" == "all" || "$token" == "a" ]]; then
      printf '%s\n' "${!REPO_NAMES[@]}"
      return
    fi

    if [[ "$token" =~ ^[0-9]+$ ]]; then
      index="$((token - 1))"
      if (( index < 0 || index >= ${#REPO_NAMES[@]} )); then
        printf 'Unknown repository number: %s\n' "$token" >&2
        return 1
      fi
      selected+=("$index")
      continue
    fi

    for index in "${!REPO_NAMES[@]}"; do
      if [[ "$token" == "${REPO_NAMES[$index]}" ]]; then
        selected+=("$index")
        continue 2
      fi
    done

    printf 'Unknown repository selection: %s\n' "$token" >&2
    return 1
  done

  if [[ "${#selected[@]}" -eq 0 ]]; then
    printf 'No repositories selected.\n' >&2
    return 1
  fi

  printf '%s\n' "${selected[@]}" | awk '!seen[$0]++'
}

clone_repo() {
  local index="$1"
  local name="${REPO_NAMES[$index]}"
  local target="$DEST_DIR/$name"
  local url

  url="$(repo_url_at "$index")"

  if [[ "$DRY_RUN" -eq 1 ]]; then
    printf 'Would clone %s from %s into %s\n' "$name" "$url" "$target"
    return
  fi

  if [[ -d "$target/.git" ]]; then
    printf 'Already cloned: %s\n' "$target"
    return
  fi

  if [[ -e "$target" ]]; then
    printf 'Skipping %s: target exists but is not a Git repository: %s\n' "$name" "$target" >&2
    return 1
  fi

  printf 'Cloning %s into %s\n' "$name" "$target"
  git clone "$url" "$target"
}

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --all)
      CLONE_ALL=1
      shift
      ;;
    --dest)
      if [[ "$#" -lt 2 ]]; then
        printf 'Missing value for --dest\n' >&2
        exit 1
      fi
      DEST_DIR="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --ssh)
      USE_SSH=1
      shift
      ;;
    --list)
      LIST_ONLY=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "$DEST_DIR" != /* ]]; then
  DEST_DIR="$ROOT_DIR/$DEST_DIR"
fi

if [[ "$LIST_ONLY" -eq 1 ]]; then
  print_repos
  exit 0
fi

if ! command -v git >/dev/null 2>&1; then
  printf 'git is required but was not found on PATH.\n' >&2
  exit 1
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
  mkdir -p "$DEST_DIR"
fi

if [[ "$CLONE_ALL" -eq 1 ]]; then
  SELECTED=("${!REPO_NAMES[@]}")
else
  printf 'Repositories will be cloned into:\n  %s\n\n' "$DEST_DIR"
  print_repos
  printf '\nSelect repositories to clone.\n'
  printf 'Use numbers or names separated by spaces/commas, or type "all".\n'
  printf 'Selection [all]: '
  read -r SELECTION
  SELECTION="${SELECTION:-all}"

  PARSED_SELECTION="$(parse_selection "$SELECTION")"
  SELECTED=()
  while IFS= read -r index; do
    if [[ -n "$index" ]]; then
      SELECTED+=("$index")
    fi
  done <<< "$PARSED_SELECTION"
fi

for index in "${SELECTED[@]}"; do
  clone_repo "$index"
done

if [[ "$DRY_RUN" -eq 1 ]]; then
  printf '\nDry run complete. No repositories were cloned.\n'
else
  printf '\nDone. Project repositories live in:\n  %s\n' "$DEST_DIR"
fi
