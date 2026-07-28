#!/usr/bin/env bash

set -euo pipefail

# Always execute from this script's directory.
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

VENV_DIR="$PROJECT_DIR/.venv"

echo "========================================"
echo "OTMS PostgreSQL Ansible Deployment"
echo "========================================"

# Controller requirements
if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR: python3 is not installed."
    exit 1
fi

if ! command -v session-manager-plugin >/dev/null 2>&1; then
    echo "ERROR: AWS Session Manager plugin is not installed."
    echo "Install it once on the local/Jenkins controller."
    exit 1
fi

if ! command -v aws >/dev/null 2>&1; then
    echo "ERROR: AWS CLI is not installed."
    exit 1
fi

# Create virtual environment only when it does not exist.
if [[ ! -x "$VENV_DIR/bin/python" ]]; then
    echo "Creating Python virtual environment..."
    python3 -m venv "$VENV_DIR"
fi

echo "Installing/verifying Python dependencies..."
"$VENV_DIR/bin/python" -m pip install --quiet --upgrade pip
"$VENV_DIR/bin/python" -m pip install --quiet -r requirements.txt

echo "Installing/verifying Ansible collections..."
"$VENV_DIR/bin/ansible-galaxy" collection install \
    -r requirements.yml

echo "Verifying AWS identity..."
aws sts get-caller-identity >/dev/null

echo "Checking dynamic inventory..."
"$VENV_DIR/bin/ansible-inventory" \
    -i inventory/aws_ec2.yml \
    --graph

echo "Checking playbook syntax..."
"$VENV_DIR/bin/ansible-playbook" \
    -i inventory/aws_ec2.yml \
    otms-dev-postgresql.yml \
    --syntax-check

echo "Running PostgreSQL playbook..."
"$VENV_DIR/bin/ansible-playbook" \
    -i inventory/aws_ec2.yml \
    otms-dev-postgresql.yml \
    "$@"
