#!/usr/bin/env bash
set -euo pipefail

if command -v gitleaks >/dev/null 2>&1; then
  echo "[security] Running gitleaks..."
  gitleaks detect --source . --no-banner
else
  echo "[security] gitleaks not installed. Install with:"
  echo "  brew install gitleaks"
  echo "or"
  echo "  mise use -g ubi:aquasecurity/trivy@latest"
  exit 1
fi
