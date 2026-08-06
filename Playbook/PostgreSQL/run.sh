#!/usr/bin/env bash

set -Eeuo pipefail

# Script fail hone par line number show karega.
trap 'echo "ERROR: PostgreSQL deployment failed near line ${LINENO}."' ERR

# run.sh jis directory mein hai, us directory ka absolute path.
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_DIR"

# Shared Library environment variables pass kar sakti hai.
# Local execution mein default values use hongi.
INVENTORY_FILE="${INVENTORY_FILE:-inventory/aws_ec2.yml}"
PLAYBOOK_FILE="${PLAYBOOK_FILE:-otms-dev-postgresql.yml}"
TARGET_GROUP="${TARGET_GROUP:-${POSTGRESQL_GROUP:-postgresql}}"

VENV_DIR="$PROJECT_DIR/.venv"
REQUIREMENTS_FILE="$PROJECT_DIR/requirements.txt"
COLLECTION_REQUIREMENTS_FILE="$PROJECT_DIR/requirements.yml"

# Relative paths ko absolute paths mein convert karo.
if [[ "$INVENTORY_FILE" != /* ]]; then
    INVENTORY_FILE="$PROJECT_DIR/$INVENTORY_FILE"
fi

if [[ "$PLAYBOOK_FILE" != /* ]]; then
    PLAYBOOK_FILE="$PROJECT_DIR/$PLAYBOOK_FILE"
fi

# Jenkins ya local environment se ANSIBLE_CONFIG supplied ho sakta hai.
ANSIBLE_CONFIG_FILE="${ANSIBLE_CONFIG:-$PROJECT_DIR/ansible.cfg}"
export ANSIBLE_CONFIG="$ANSIBLE_CONFIG_FILE"

echo "=================================================="
echo "       OTMS PostgreSQL Ansible Deployment"
echo "=================================================="
echo "Project directory : $PROJECT_DIR"
echo "Ansible config    : $ANSIBLE_CONFIG_FILE"
echo "Inventory file    : $INVENTORY_FILE"
echo "Playbook file     : $PLAYBOOK_FILE"
echo "Target group      : $TARGET_GROUP"
echo "=================================================="

echo
echo "Checking required project files..."

required_files=(
    "$ANSIBLE_CONFIG_FILE"
    "$INVENTORY_FILE"
    "$PLAYBOOK_FILE"
    "$REQUIREMENTS_FILE"
    "$COLLECTION_REQUIREMENTS_FILE"
)

for required_file in "${required_files[@]}"; do
    if [[ ! -f "$required_file" ]]; then
        echo "ERROR: Required file not found: $required_file"
        exit 1
    fi
done

echo "All required project files are present."

echo
echo "Checking controller prerequisites..."

required_commands=(
    python3
    aws
    session-manager-plugin
)

for command_name in "${required_commands[@]}"; do
    if ! command -v "$command_name" >/dev/null 2>&1; then
        echo "ERROR: Required command '$command_name' is not installed."
        echo
        echo "Required controller tools:"
        echo "  - python3"
        echo "  - python3-venv"
        echo "  - AWS CLI"
        echo "  - AWS Session Manager plugin"
        exit 1
    fi

    echo "Found: $command_name"
done

echo
echo "Preparing Python virtual environment..."

if [[ ! -x "$VENV_DIR/bin/python" ]]; then
    echo "Virtual environment does not exist."
    echo "Creating: $VENV_DIR"

    if ! python3 -m venv "$VENV_DIR"; then
        echo "ERROR: Unable to create Python virtual environment."
        echo "On Ubuntu, install python3-venv using:"
        echo "sudo apt update && sudo apt install -y python3-venv"
        exit 1
    fi

    echo "Virtual environment created successfully."
else
    echo "Using existing virtual environment: $VENV_DIR"
fi

echo
echo "Installing/verifying Python dependencies..."

"$VENV_DIR/bin/python" -m pip install \
    --disable-pip-version-check \
    -r "$REQUIREMENTS_FILE"

echo
echo "Installing/verifying Ansible collections..."

"$VENV_DIR/bin/ansible-galaxy" collection install \
    -r "$COLLECTION_REQUIREMENTS_FILE"

echo
echo "Displaying Ansible version..."

"$VENV_DIR/bin/ansible-playbook" --version

echo
echo "Verifying AWS credentials and identity..."

aws sts get-caller-identity

echo
echo "Validating AWS EC2 dynamic inventory..."

INVENTORY_JSON_FILE="$(mktemp)"

cleanup() {
    rm -f "$INVENTORY_JSON_FILE"
}

trap cleanup EXIT

"$VENV_DIR/bin/ansible-inventory" \
    -i "$INVENTORY_FILE" \
    --list > "$INVENTORY_JSON_FILE"

"$VENV_DIR/bin/ansible-inventory" \
    -i "$INVENTORY_FILE" \
    --graph

echo
echo "Checking hosts in Ansible group: $TARGET_GROUP"

HOST_COUNT="$(
    "$VENV_DIR/bin/python" \
        - "$INVENTORY_JSON_FILE" "$TARGET_GROUP" <<'PYTHON'
import json
import sys
from pathlib import Path

inventory_file = Path(sys.argv[1])
group_name = sys.argv[2]

try:
    with inventory_file.open(encoding="utf-8") as file:
        inventory = json.load(file)
except (OSError, json.JSONDecodeError) as error:
    print(f"Unable to read dynamic inventory JSON: {error}", file=sys.stderr)
    sys.exit(1)

group_data = inventory.get(group_name, {})
hosts = group_data.get("hosts", [])

print(len(hosts))
PYTHON
)"

if [[ "$HOST_COUNT" -eq 0 ]]; then
    echo "ERROR: No EC2 instance found in inventory group '$TARGET_GROUP'."
    echo
    echo "Verify the following:"
    echo "  - EC2 instance is running"
    echo "  - Name tag is dev-otms-postgresql-ec2"
    echo "  - Environment tag is dev"
    echo "  - AWS region is us-east-1"
    echo "  - Jenkins/local AWS credentials have EC2 Describe permissions"
    exit 1
fi

echo "Dynamic inventory found $HOST_COUNT host(s) in '$TARGET_GROUP'."

echo
echo "Validating PostgreSQL playbook syntax..."

"$VENV_DIR/bin/ansible-playbook" \
    -i "$INVENTORY_FILE" \
    "$PLAYBOOK_FILE" \
    --syntax-check

echo
echo "Playbook syntax validation completed successfully."

echo
echo "=================================================="
echo "Running PostgreSQL Ansible playbook"
echo "=================================================="

"$VENV_DIR/bin/ansible-playbook" \
    -i "$INVENTORY_FILE" \
    "$PLAYBOOK_FILE" \
    "$@"

echo
echo "=================================================="
echo "PostgreSQL deployment completed successfully."
echo "=================================================="
