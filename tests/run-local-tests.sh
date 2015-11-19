#!/usr/bin/env bash

# Check syntax:
ansible-playbook provisioning/site-test.yml --syntax-check

# Apply playbook:
ansible-playbook provisioning/site-test.yml

# Apply again to check idempotency:
# Note: The 'remove user' scenario is permitted to fail this check
ansible-playbook provisioning/site-test.yml
