#!/usr/bin/env bash

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

VENV_DIR="$PROJECT_DIR/.venv"

echo "========================================"
echo "OTMS PostgreSQL Ansible Deployment"
echo "========================================"

for command_name in python3 aws session-manager-plugin; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "ERROR: Required command '$command_name' is not installed."
        exit 1
    fi
done

if [[ ! -x "$VENV_DIR/bin/python" ]]; then
    echo "Creating virtual environment..."
    python3 -m venv "$VENV_DIR"

    echo "Installing Python dependencies..."
    "$VENV_DIR/bin/python" -m pip install -r requirements.txt
else
    echo "Using existing virtual environment."
    "$VENV_DIR/bin/python" -m pip install -r requirements.txt
fi

echo "Installing/verifying Ansible collections..."
"$VENV_DIR/bin/ansible-galaxy" collection install \
    -r requirements.yml

echo "Verifying AWS credentials..."
aws sts get-caller-identity

echo "Validating dynamic inventory..."
"$VENV_DIR/bin/ansible-inventory" \
    -i inventory/aws_ec2.yml \
    --graph

echo "Validating playbook syntax..."
"$VENV_DIR/bin/ansible-playbook" \
    -i inventory/aws_ec2.yml \
    otms-dev-postgresql.yml \
    --syntax-check

echo "Running PostgreSQL playbook..."
"$VENV_DIR/bin/ansible-playbook" \
    -i inventory/aws_ec2.yml \
    otms-dev-postgresql.yml \
    "$@"
