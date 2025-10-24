#!/usr/bin/env bash

# Installs Docker, Docker Compose, Python (>=3.9), and Django on Ubuntu/Debian.
# The script is idempotent: it checks for existing installations before acting.

set -o errexit
set -o nounset
set -o pipefail

log() {
  echo "[INFO] $*"
}

warn() {
  echo "[WARN] $*" >&2
}

err() {
  echo "[ERROR] $*" >&2
}

require_sudo() {
  if [[ $(id -u) -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
      SUDO="sudo"
    else
      err "This script requires root privileges or sudo. Please run as root or install sudo."
      exit 1
    fi
  else
    SUDO=""
  fi
}

ensure_ubuntu_debian() {
  if [[ -r /etc/os-release ]]; then
    # shellcheck disable=SC1091
    . /etc/os-release
    case "${ID:-}" in
      ubuntu|debian)
        :
        ;;
      *)
        err "Unsupported OS: ${ID:-unknown}. This script supports Ubuntu/Debian only."
        exit 1
        ;;
    esac
  else
    err "/etc/os-release not found. Unable to detect OS."
    exit 1
  fi
}

apt_update_once() {
  if [[ -z "${APT_UPDATED:-}" ]]; then
    log "Updating apt package index..."
    ${SUDO} apt-get update -y
    APT_UPDATED=1
  fi
}

install_prereqs() {
  apt_update_once
  log "Installing prerequisites (ca-certificates, curl, gnupg, lsb-release)..."
  ${SUDO} apt-get install -y ca-certificates curl gnupg lsb-release apt-transport-https software-properties-common
}

install_docker() {
  if command -v docker >/dev/null 2>&1; then
    log "Docker is already installed: $(docker --version)"
    return 0
  fi

  log "Installing Docker Engine..."
  install_prereqs

  # Add Docker’s official GPG key
  if [[ ! -f /etc/apt/keyrings/docker.gpg ]]; then
    ${SUDO} install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/$(. /etc/os-release && echo "$ID")/gpg | ${SUDO} gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    ${SUDO} chmod a+r /etc/apt/keyrings/docker.gpg
  fi

  # Add the repository to Apt sources
  if [[ ! -f /etc/apt/sources.list.d/docker.list ]]; then
    local arch
    arch=$(dpkg --print-architecture)
    local codename
    codename=$(. /etc/os-release && echo "$VERSION_CODENAME")
    echo \
"deb [arch=${arch} signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$(. /etc/os-release && echo "$ID") ${codename} stable" | ${SUDO} tee /etc/apt/sources.list.d/docker.list >/dev/null
  fi

  APT_UPDATED="" # force update after adding repo
  apt_update_once

  ${SUDO} apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  log "Docker installed: $(docker --version)"
}

ensure_docker_compose() {
  # Prefer Docker Compose v2 (`docker compose`)
  if docker compose version >/dev/null 2>&1; then
    log "Docker Compose v2 is already available: $(docker compose version | head -n1)"
    return 0
  fi

  log "Installing Docker Compose plugin (v2)..."
  APT_UPDATED=""; apt_update_once
  if ${SUDO} apt-get install -y docker-compose-plugin; then
    log "Docker Compose plugin installed: $(docker compose version | head -n1 || echo 'installed')"
    return 0
  fi

  # Fallback to docker-compose v1 if plugin not available
  warn "docker-compose-plugin not available. Falling back to docker-compose v1 from apt."
  APT_UPDATED=""; apt_update_once
  if ${SUDO} apt-get install -y docker-compose; then
    log "docker-compose installed: $(docker-compose --version)"
    return 0
  fi

  err "Failed to install Docker Compose. Please install manually."
  exit 1
}

version_ge() {
  # returns 0 if $1 >= $2
  printf '%s\n%s\n' "$1" "$2" | sort -V -C
}

ensure_python39_plus() {
  local py_cmd="python3"
  local py_ver=""

  if command -v ${py_cmd} >/dev/null 2>&1; then
    py_ver=$(${py_cmd} -V 2>&1 | awk '{print $2}')
    if version_ge "${py_ver}" "3.9"; then
      log "Python already installed: ${py_cmd} ${py_ver}"
    else
      warn "Python version ${py_ver} is < 3.9. Attempting to install newer Python."
      install_newer_python
      py_ver=$(${py_cmd} -V 2>&1 | awk '{print $2}') || true
    fi
  else
    warn "python3 not found. Installing Python 3.9+"
    install_newer_python
    py_ver=$(${py_cmd} -V 2>&1 | awk '{print $2}') || true
  fi

  if [[ -z "${py_ver}" ]] || ! version_ge "${py_ver}" "3.9"; then
    err "Failed to ensure Python >= 3.9."
    exit 1
  fi

  APT_UPDATED=""; apt_update_once
  ${SUDO} apt-get install -y python3-pip python3-venv
  log "Python ready: ${py_cmd} ${py_ver} | pip3 $(pip3 --version | awk '{print $2}')"
}

install_newer_python() {
  install_prereqs
  APT_UPDATED=""; apt_update_once

  # Try installing progressively newer Python versions, stopping on first success
  local candidates=(python3.12 python3.11 python3.10 python3.9)
  local installed=false
  for pkg in "${candidates[@]}"; do
    if ${SUDO} apt-get install -y "$pkg"; then
      installed=true
      break
    fi
  done

  if [[ "${installed}" != "true" ]]; then
    # As a last resort, attempt deadsnakes PPA on Ubuntu
    if grep -qi ubuntu /etc/os-release; then
      warn "Attempting to add deadsnakes PPA for newer Python on Ubuntu..."
      ${SUDO} add-apt-repository -y ppa:deadsnakes/ppa || true
      APT_UPDATED=""; apt_update_once
      ${SUDO} apt-get install -y python3.11 || ${SUDO} apt-get install -y python3.10 || ${SUDO} apt-get install -y python3.9 || true
    fi
  fi
}

install_django() {
  if python3 -m pip show django >/dev/null 2>&1; then
    local dj_ver
    dj_ver=$(python3 -m django --version 2>/dev/null || true)
    log "Django already installed: ${dj_ver:-unknown}"
    return 0
  fi

  log "Installing/Upgrading pip..."
  python3 -m pip install --upgrade pip >/dev/null 2>&1 || ${SUDO} python3 -m pip install --upgrade pip

  log "Installing Django via pip..."
  if python3 -m pip install --upgrade Django; then
    log "Django installed: $(python3 -m django --version)"
  else
    warn "User install failed; attempting system-wide install with sudo."
    ${SUDO} python3 -m pip install --upgrade Django
    log "Django installed: $(python3 -m django --version)"
  fi
}

print_summary() {
  echo "\n================ Summary ================"
  if command -v docker >/dev/null 2>&1; then docker --version; else echo "docker: not installed"; fi
  if docker compose version >/dev/null 2>&1; then docker compose version | head -n1; elif command -v docker-compose >/dev/null 2>&1; then docker-compose --version; else echo "docker compose: not installed"; fi
  if command -v python3 >/dev/null 2>&1; then python3 -V; else echo "python3: not installed"; fi
  if python3 -m django --version >/dev/null 2>&1; then echo "Django $(python3 -m django --version)"; else echo "Django: not installed"; fi
  echo "========================================\n"
}

main() {
  require_sudo
  ensure_ubuntu_debian

  install_docker
  ensure_docker_compose
  ensure_python39_plus
  install_django

  print_summary
  log "All done."
}

main "$@"


