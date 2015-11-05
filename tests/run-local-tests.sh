#!/usr/bin/env bash

# Check syntax:
ansible-playbook -i provisioning/site-test.yml --syntax-check

# Apply playbook:
ansible-playbook -i provisioning/site-test.yml

# Apply again to check idempotency:
ansible-playbook -i provisioning/site-test.yml
