#!/usr/bin/env bash

# Check syntax:
ansible-playbook provisioning/site-test.yml --syntax-check

# Apply playbook:
ansible-playbook provisioning/site-test.yml

# Apply again to check idempotency:
ansible-playbook provisioning/site-test.yml
