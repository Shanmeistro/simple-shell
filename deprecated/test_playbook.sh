#!/bin/bash
# test_playbook.sh - Quick test script for development

# Activate venv if it exists (for development)
if [ -d ".venv" ]; then
    echo "🐍 Activating Python virtual environment..."
    source .venv/bin/activate
fi

# Check if ansible is available
if ! command -v ansible-playbook &> /dev/null; then
    echo "❌ ansible-playbook not found!"
    echo "For testing, please activate your venv or install Ansible system-wide."
    exit 1
fi

echo "🧪 Testing Ansible Playbook..."
echo "================================"

# Syntax check first
echo "1. Checking syntax..."
ansible-playbook ansible/custom_dev_env.yml --syntax-check

if [ $? -ne 0 ]; then
    echo "❌ Syntax check failed!"
    exit 1
fi

echo "✅ Syntax OK"
echo ""

# Dry run with check mode
echo "2. Running dry-run (check mode)..."
ansible-playbook ansible/custom_dev_env.yml \
  --check \
  --diff \
  --ask-become-pass \
  --extra-vars "preferred_shell=/usr/bin/zsh prompt_framework=starship" \
  -v

echo ""
echo "✅ Test complete!"
