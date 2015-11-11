# System Users (`system-users`)

Creates one or more operating system users with various optional attributes.

## Usage

### Setting default options

TODO: Describe (its not possible to chain the 'default' filter to try multiple values).

```yaml
---

system_users_defaults:
  - shell: /bin/bash

system_users_users:
  -
    username: user1
    shell: "{{ system_users_defaults.shell }}"
    state: present
  -
    username: user2
    shell: "{{ system_users_defaults.shell }}"
    state: present
```
