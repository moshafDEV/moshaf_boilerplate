#!/bin/bash
set -euo pipefail
mkdir -p ~/jenkins-agent
python3 "$(dirname "$0")/report-stage-status.py" "$@"
