#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT}"

readonly -a SERVICE_ACTIONS=(start stop restart run status)
readonly -a RELEASE_ACTIONS=(install-dev install-prod upgrade rollback)
readonly -a ACTIONS=("${SERVICE_ACTIONS[@]}" "${RELEASE_ACTIONS[@]}")
readonly -a TARGETS=(api sdk all)

usage() {
  printf 'Usage: %s <start|stop|restart|run|status|install-dev> <api|sdk|all>\n' "${0##*/}" >&2
  printf '       %s <install-prod|upgrade> <api|sdk|all> [version]\n' "${0##*/}" >&2
  printf '       %s rollback <api|sdk|all> <version>\n' "${0##*/}" >&2
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 2
}

contains() {
  local needle="$1"
  shift
  local item
  for item in "$@"; do
    [[ "${item}" == "${needle}" ]] && return 0
  done
  return 1
}

choose() {
  command -v gum >/dev/null 2>&1 ||
    die "missing argument and gum is unavailable; run with explicit arguments"
  gum choose "$@"
}

# Service apps: something starts these as a long-running process. Only
# these accept service actions (start/stop/restart/run/status). Register an
# app here yourself -- never infer this from its name (see rules.md's App
# Category & Lifecycle Requirement).
resolve_service_app() {
  case "$1" in
    api) printf '%s\n' "apps/funmill-api" ;;
    *) return 1 ;;
  esac
}

# Package apps: installed as a dependency, never started as their own
# process. funmill-sdk is a Python client library consumed by other
# services, so it is registered here instead of resolve_service_app.
resolve_package_app() {
  case "$1" in
    sdk) printf '%s\n' "apps/funmill-sdk" ;;
    *) return 1 ;;
  esac
}

# Release actions (install-dev/install-prod/upgrade/rollback) apply to
# service apps and package apps alike. Nested-workspace apps resolve through
# neither this nor resolve_service_app -- there are none in this workspace.
resolve_release_app() {
  resolve_service_app "$1" 2>/dev/null || resolve_package_app "$1" 2>/dev/null
}

is_service_action() {
  contains "$1" "${SERVICE_ACTIONS[@]}"
}

dispatch_app_action() {
  local action="$1" target="$2" version="${3:-}" app path
  local -a apps
  if [[ "${target}" == "all" ]]; then
    if is_service_action "${action}"; then
      apps=(api)  # every registered service app
    else
      apps=(api sdk)  # every registered service + package app
    fi
  else
    apps=("${target}")
  fi
  for app in "${apps[@]}"; do
    if is_service_action "${action}"; then
      path="$(resolve_service_app "${app}")" || die "${action} only applies to a service app, not: ${app}"
    else
      path="$(resolve_release_app "${app}")" || die "${action} does not apply to: ${app}"
    fi
    printf '== %s: %s ==\n' "${app}" "${action}"
    (cd "${path}" && ./scripts/setup.sh "${action}" ${version:+"${version}"})
  done
}

main() {
  local action="${1:-}"
  local target="${2:-}"
  local version="${3:-}"

  [[ -n "${action}" ]] || action="$(choose "${ACTIONS[@]}")"
  contains "${action}" "${ACTIONS[@]}" || {
    usage
    die "unknown action: ${action}"
  }

  [[ -n "${target}" ]] || target="$(choose "${TARGETS[@]}")"

  case "${action}" in
    rollback)
      [[ -n "${version}" ]] || die "rollback requires an explicit version: ${0##*/} rollback <api|sdk|all> <version>"
      contains "${target}" "${TARGETS[@]}" || {
        usage
        die "unknown target: ${target}"
      }
      dispatch_app_action "${action}" "${target}" "${version}"
      ;;
    *)
      contains "${target}" "${TARGETS[@]}" || {
        usage
        die "unknown target: ${target}"
      }
      dispatch_app_action "${action}" "${target}" "${version}"
      ;;
  esac
}

main "$@"
